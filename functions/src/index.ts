import {onDocumentUpdated} from "firebase-functions/v2/firestore";
import {logger} from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

const db = admin.firestore();
const fcm = admin.messaging();

export const onLeaveRequestUpdate = onDocumentUpdated(
    "leaveRequests/{requestId}",
    async (event) => {
      logger.log(`Function triggered for request ID: ${event.params.requestId}`);

      const beforeData = event.data?.before.data();
      const afterData = event.data?.after.data();

      if (!beforeData || !afterData) {
        logger.log(
            "Data is missing in before or after snapshot. Exiting function."
        );
        return;
      }

      if (beforeData.status === afterData.status) {
        logger.log("Status unchanged. No notification sent.");
        return;
      }

      if (beforeData.status !== "Pending") {
        logger.log(
            "Status changed, but not 'Pending' before. No notification sent."
        );
        return;
      }

      const userId = afterData.userId;
      const newStatus = afterData.status;

      if (!userId) {
        logger.error("User ID is missing from the request data.", afterData);
        return;
      }

      const userDoc = await db.collection("users").doc(userId).get();
      if (!userDoc.exists) {
        logger.error(`User document for user ID '${userId}' not found.`);
        return;
      }

      const userData = userDoc.data();
      const token = userData?.deviceToken;

      if (!token) {
        logger.warn(
            `User ${userId} does not have a device token. Cannot send.`
        );
        return;
      }

      const requestDate = (afterData.date as admin.firestore.Timestamp)
          .toDate()
          .toLocaleDateString();

      const payload = {
        notification: {
          title: `Request ${newStatus}!`,
          body: `Your ${
            afterData.requestType
          } request for ${requestDate} has been ${newStatus.toLowerCase()}.`,
          sound: "default",
        },
      };

      logger.log(`Sending notification to token: ${token}`);
      await fcm.sendToDevice(token, payload);
      logger.log("Successfully sent notification.");
    },
);