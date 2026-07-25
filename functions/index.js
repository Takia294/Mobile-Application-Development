/**
 * ============================================================
 * LifeLink — Cloud Functions
 *
 * Referenced by push_notification_service.dart's doc comment: the app
 * already writes documents into `notifications` and shows them in-app
 * (see NotificationService / NotificationScreen), and every device
 * saves its FCM token onto its own `users/{uid}` doc and subscribes to
 * the 'all_users' topic. This function is the missing other half — it
 * listens for new `notifications` docs and actually sends the device
 * push:
 *   - targetUid === 'all'  -> send to the 'all_users' topic
 *   - targetUid === <uid>  -> send directly to that user's saved fcmToken
 *
 * Deploy with:  firebase deploy --only functions
 * ============================================================
 */
const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');
const { logger } = require('firebase-functions');

initializeApp();
const db = getFirestore();
const messaging = getMessaging();

exports.onNotificationCreated = onDocumentCreated(
  'notifications/{notificationId}',
  async (event) => {
    const data = event.data?.data();
    if (!data) return;

    const { targetUid, type, title, subtitle } = data;

    const notification = {
      title: title || 'LifeLink',
      body: subtitle || '',
    };
    const payloadData = {
      type: type || 'info',
      notificationId: event.params.notificationId,
    };

    try {
      if (targetUid === 'all') {
        await messaging.send({
          topic: 'all_users',
          notification,
          data: payloadData,
        });
        logger.info(`Broadcast push sent for notification ${event.params.notificationId}`);
        return;
      }

      // Personal notification — look up that user's saved FCM token.
      const userDoc = await db.collection('users').doc(targetUid).get();
      const token = userDoc.data()?.fcmToken;

      if (!token) {
        logger.info(`No FCM token for user ${targetUid}, skipping push (in-app alert still works).`);
        return;
      }

      await messaging.send({
        token,
        notification,
        data: payloadData,
      });
      logger.info(`Personal push sent to ${targetUid} for notification ${event.params.notificationId}`);
    } catch (err) {
      // Non-fatal — the in-app notification list (Firestore doc itself)
      // is already saved regardless of whether the push succeeds.
      logger.error('Failed to send push notification', err);
    }
  }
);
