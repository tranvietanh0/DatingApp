import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

/**
 * Scheduled function to clean up expired matches
 * Runs every hour to delete matches that have expired
 */
export const cleanupExpiredMatches = functions.pubsub
  .schedule("every 1 hours")
  .onRun(async () => {
    const now = admin.firestore.Timestamp.now();

    // Find expired matches that haven't had any messages
    const expiredMatches = await db
      .collection("matches")
      .where("bumbleMode", "==", true)
      .where("expiresAt", "<", now)
      .where("lastMessage", "==", null)
      .get();

    if (expiredMatches.empty) {
      console.log("No expired matches to clean up");
      return null;
    }

    const batch = db.batch();
    let count = 0;

    for (const doc of expiredMatches.docs) {
      batch.delete(doc.ref);
      count++;

      // Firestore batch limit is 500
      if (count >= 500) {
        break;
      }
    }

    await batch.commit();
    console.log(`Cleaned up ${count} expired matches`);

    return null;
  });
