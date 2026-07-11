/**
 * ============================================================
 * LIFELINK — CLOUD FUNCTIONS
 *
 * The app writes plain Firestore documents into `notifications`
 * (see NotificationService.sendBroadcast / sendToUser). Those show
 * up instantly in the in-app Notification screen, but only while
 * the app is open. This function bridges that to a real device
 * push notification the moment a document is created:
 *
 *   - targetUid == 'all'  -> push to the 'all_users' FCM topic
 *                            (every device subscribes to this on
 *                            login — see PushNotificationService)
 *   - targetUid == <uid>  -> push directly to that user's saved
 *                            fcmToken on their users/{uid} doc
 *
 * REQUIRES the Blaze (pay-as-you-go) plan — Cloud Functions don't
 * run on the free Spark plan. In practice, this function only runs
 * when someone submits an emergency request or an admin sends an
 * alert, so cost is negligible for a student/small-scale project.
 *
 * Deploy:
 *   cd functions && npm install
 *   firebase deploy --only functions
 * ============================================================
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendNotificationPush = functions.firestore
  .document('notifications/{notificationId}')
  .onCreate(async (snap) => {
    const data = snap.data();
    if (!data) return null;

    const notificationPayload = {
      title: data.title || 'LifeLink',
      body: data.subtitle || '',
    };
    const dataPayload = {
      type: data.type || 'info',
      notificationId: snap.id,
    };

    try {
      if (data.targetUid === 'all') {
        await admin.messaging().send({
          topic: 'all_users',
          notification: notificationPayload,
          data: dataPayload,
        });
        console.log('Broadcast push sent for notification', snap.id);
        return null;
      }

      if (!data.targetUid) return null;

      const userDoc = await admin
        .firestore()
        .collection('users')
        .doc(data.targetUid)
        .get();

      const token = userDoc.exists ? userDoc.data().fcmToken : null;
      if (!token) {
        console.log('No fcmToken for target user', data.targetUid, '- skipping push');
        return null;
      }

      await admin.messaging().send({
        token,
        notification: notificationPayload,
        data: dataPayload,
      });
      console.log('Personal push sent to', data.targetUid);
    } catch (err) {
      // A push failure should never break notification creation itself —
      // the in-app notification document already exists regardless.
      console.error('Failed to send push for notification', snap.id, err);
    }

    return null;
  });

/**
 * Optional companion to the client-side request-expiry logic in
 * RequestModel.displayStatus. That client-side check already makes
 * old requests correctly show/behave as "Expired" everywhere in the
 * app without needing this function. This scheduled job additionally
 * PERSISTS that as the real Firestore status once a day, which is
 * only useful if you query `requests` from outside the app (e.g. a
 * future admin export/report) and want the stored status to already
 * reflect expiry. Safe to skip deploying this one if you don't need
 * that — everything in-app already works without it.
 */
exports.expireStaleRequests = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async () => {
    const staleAfterDays = 7;
    const cutoff = admin.firestore.Timestamp.fromMillis(
      Date.now() - staleAfterDays * 24 * 60 * 60 * 1000
    );

    const snap = await admin
      .firestore()
      .collection('requests')
      .where('status', 'in', ['Active', 'Pending', 'Critical'])
      .where('createdAt', '<=', cutoff)
      .get();

    if (snap.empty) return null;

    const batch = admin.firestore().batch();
    snap.docs.forEach((doc) => batch.update(doc.ref, { status: 'Expired' }));
    await batch.commit();
    console.log(`Marked ${snap.size} stale request(s) as Expired`);
    return null;
  });
