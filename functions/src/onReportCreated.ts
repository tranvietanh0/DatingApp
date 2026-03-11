import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

const MAX_REPORTS_BEFORE_REVIEW = 3;

/**
 * Triggered when a new report is created
 * Checks if user should be flagged for review
 */
export const onReportCreated = functions.firestore
  .document("reports/{reportId}")
  .onCreate(async (snap, context) => {
    const report = snap.data();
    const reportedUserId = report.reportedId;

    // Count pending reports for this user
    const reportsSnapshot = await db
      .collection("reports")
      .where("reportedId", "==", reportedUserId)
      .where("status", "==", "pending")
      .get();

    const reportCount = reportsSnapshot.size;

    if (reportCount >= MAX_REPORTS_BEFORE_REVIEW) {
      // Flag user for moderation review
      await db.collection("moderation_queue").doc(reportedUserId).set(
        {
          userId: reportedUserId,
          reason: `${reportCount} reports received`,
          reportIds: reportsSnapshot.docs.map((doc) => doc.id),
          flaggedAt: admin.firestore.FieldValue.serverTimestamp(),
          status: "pending",
          priority: reportCount >= 5 ? "high" : "normal",
        },
        { merge: true }
      );

      // Send notification to moderation team (could be Slack, email, etc.)
      console.log(`User ${reportedUserId} flagged for review: ${reportCount} reports`);
    }

    return null;
  });

/**
 * Triggered when moderation status changes
 * Takes action on the user account
 */
export const onModerationAction = functions.firestore
  .document("moderation_queue/{userId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const userId = context.params.userId;

    // Only process if status changed
    if (before.status === after.status) {
      return null;
    }

    const newStatus = after.status;

    if (newStatus === "banned") {
      // Ban the user
      await db.collection("users").doc(userId).update({
        moderationStatus: "banned",
        isVisible: false,
      });

      // Could also delete their active matches, disable auth, etc.
      console.log(`User ${userId} has been banned`);
    } else if (newStatus === "suspended") {
      // Suspend the user for 7 days
      const suspensionEnd = new Date();
      suspensionEnd.setDate(suspensionEnd.getDate() + 7);

      await db.collection("users").doc(userId).update({
        moderationStatus: "suspended",
        isVisible: false,
        suspensionEndsAt: admin.firestore.Timestamp.fromDate(suspensionEnd),
      });

      console.log(`User ${userId} has been suspended until ${suspensionEnd}`);
    } else if (newStatus === "warned") {
      // Issue warning
      await db.collection("users").doc(userId).update({
        moderationStatus: "warned",
        lastWarningAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Send FCM notification about warning
      const userDoc = await db.collection("users").doc(userId).get();
      const fcmToken = userDoc.data()?.fcmToken;

      if (fcmToken) {
        await admin.messaging().send({
          token: fcmToken,
          notification: {
            title: "Account Warning",
            body: "Your account has received a warning for policy violations.",
          },
        });
      }

      console.log(`User ${userId} has been warned`);
    } else if (newStatus === "cleared") {
      // Clear the user - no action needed, just resolve reports
      await db.collection("users").doc(userId).update({
        moderationStatus: "active",
      });

      // Mark all pending reports as reviewed
      const reports = await db
        .collection("reports")
        .where("reportedId", "==", userId)
        .where("status", "==", "pending")
        .get();

      const batch = db.batch();
      for (const doc of reports.docs) {
        batch.update(doc.ref, { status: "reviewed" });
      }
      await batch.commit();

      console.log(`User ${userId} has been cleared`);
    }

    return null;
  });
