import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

interface MessageData {
  senderId: string;
  text: string;
  sentAt: admin.firestore.Timestamp;
  isRead: boolean;
}

export const onMessageCreated = functions.firestore
  .document("matches/{matchId}/messages/{messageId}")
  .onCreate(async (snap, context) => {
    const { matchId } = context.params;
    const message = snap.data() as MessageData;

    // Get the match document to find the recipient
    const matchDoc = await db.collection("matches").doc(matchId).get();
    if (!matchDoc.exists) {
      return null;
    }

    const match = matchDoc.data();
    if (!match) {
      return null;
    }

    // Find the recipient (the user who is not the sender)
    const recipientId = match.userIds.find(
      (id: string) => id !== message.senderId
    );
    if (!recipientId) {
      return null;
    }

    // Update the match with last message info and set unread for recipient
    await db.collection("matches").doc(matchId).update({
      lastMessage: message.text,
      lastMessageAt: message.sentAt,
      [`unread.${recipientId}`]: true,
    });

    // Get sender and recipient info for notification
    const [senderDoc, recipientDoc] = await Promise.all([
      db.collection("users").doc(message.senderId).get(),
      db.collection("users").doc(recipientId).get(),
    ]);

    const sender = senderDoc.data();
    const recipient = recipientDoc.data();

    // Send push notification to recipient
    if (recipient?.fcmToken) {
      await sendPushNotification(
        recipient.fcmToken,
        sender?.name || "Someone",
        message.text,
        matchId
      );
    }

    return null;
  });

async function sendPushNotification(
  token: string,
  senderName: string,
  messageText: string,
  matchId: string
): Promise<void> {
  try {
    await admin.messaging().send({
      token: token,
      notification: {
        title: senderName,
        body: messageText.length > 100
          ? messageText.substring(0, 97) + "..."
          : messageText,
      },
      data: {
        type: "new_message",
        matchId: matchId,
      },
      android: {
        priority: "high",
        notification: {
          channelId: "messages",
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
