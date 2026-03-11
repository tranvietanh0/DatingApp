import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

interface SwipeData {
  swiperId: string;
  targetId: string;
  action: "like" | "pass" | "superLike";
  timestamp: admin.firestore.Timestamp;
}

export const onSwipeCreated = functions.firestore
  .document("swipes/{swipeId}")
  .onCreate(async (snap, context) => {
    const swipe = snap.data() as SwipeData;

    // Only check for match on likes
    if (swipe.action !== "like" && swipe.action !== "superLike") {
      return null;
    }

    // Check if target has already liked the swiper
    const reverseSwipeQuery = await db
      .collection("swipes")
      .where("swiperId", "==", swipe.targetId)
      .where("targetId", "==", swipe.swiperId)
      .where("action", "in", ["like", "superLike"])
      .limit(1)
      .get();

    if (reverseSwipeQuery.empty) {
      // No mutual like yet
      return null;
    }

    // It's a match! Create match document
    const userIds = [swipe.swiperId, swipe.targetId].sort();
    const matchId = userIds.join("_");

    // Check if match already exists
    const existingMatch = await db.collection("matches").doc(matchId).get();
    if (existingMatch.exists) {
      return null;
    }

    // Check if Bumble mode is enabled
    const configDoc = await db.collection("config").doc("app").get();
    const bumbleModeEnabled = configDoc.data()?.bumbleModeEnabled ?? false;

    // Determine first message sender for Bumble mode
    let firstMessageSenderId: string | null = null;
    let expiresAt: admin.firestore.Timestamp | null = null;

    if (bumbleModeEnabled) {
      const [user1Doc, user2Doc] = await Promise.all([
        db.collection("users").doc(swipe.swiperId).get(),
        db.collection("users").doc(swipe.targetId).get(),
      ]);

      const user1Gender = user1Doc.data()?.gender;
      const user2Gender = user2Doc.data()?.gender;

      // Women message first in heterosexual matches
      if (user1Gender === "female" && user2Gender === "male") {
        firstMessageSenderId = swipe.swiperId;
      } else if (user1Gender === "male" && user2Gender === "female") {
        firstMessageSenderId = swipe.targetId;
      }
      // For same-sex matches, either can message first (no restriction)

      // Set expiry to 24 hours from now
      const expiryDate = new Date();
      expiryDate.setHours(expiryDate.getHours() + 24);
      expiresAt = admin.firestore.Timestamp.fromDate(expiryDate);
    }

    // Create the match
    await db.collection("matches").doc(matchId).set({
      userIds: userIds,
      matchedAt: admin.firestore.FieldValue.serverTimestamp(),
      lastMessageAt: admin.firestore.FieldValue.serverTimestamp(),
      unread: {
        [swipe.swiperId]: true,
        [swipe.targetId]: true,
      },
      bumbleMode: bumbleModeEnabled,
      firstMessageSenderId: firstMessageSenderId,
      expiresAt: expiresAt,
      isExtended: false,
    });

    // Send push notifications to both users
    await sendMatchNotifications(swipe.swiperId, swipe.targetId);

    return null;
  });

async function sendMatchNotifications(
  userId1: string,
  userId2: string
): Promise<void> {
  const [user1Doc, user2Doc] = await Promise.all([
    db.collection("users").doc(userId1).get(),
    db.collection("users").doc(userId2).get(),
  ]);

  const user1 = user1Doc.data();
  const user2 = user2Doc.data();

  const notifications: Promise<void>[] = [];

  // Get FCM tokens and send notifications
  if (user1?.fcmToken) {
    notifications.push(
      sendPushNotification(
        user1.fcmToken,
        "New Match!",
        `You matched with ${user2?.name || "someone"}!`
      )
    );
  }

  if (user2?.fcmToken) {
    notifications.push(
      sendPushNotification(
        user2.fcmToken,
        "New Match!",
        `You matched with ${user1?.name || "someone"}!`
      )
    );
  }

  await Promise.all(notifications);
}

async function sendPushNotification(
  token: string,
  title: string,
  body: string
): Promise<void> {
  try {
    await admin.messaging().send({
      token: token,
      notification: {
        title: title,
        body: body,
      },
      android: {
        priority: "high",
        notification: {
          channelId: "matches",
        },
      },
      apns: {
        payload: {
          aps: {
            badge: 1,
            sound: "default",
          },
        },
      },
    });
  } catch (error) {
    console.error("Error sending push notification:", error);
  }
}
