import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// ============================================================
/// PUSH NOTIFICATION SERVICE
///
/// The app already writes documents into the `notifications`
/// Firestore collection (see NotificationService) and shows them
/// in-app on NotificationScreen. That alone only works while the
/// app is open. This service adds real device push notifications
/// on top of that:
///
///   1. Every signed-in device subscribes to the 'all_users' FCM
///      topic, and saves its token onto its own `users/{uid}`
///      document (`fcmToken` field).
///   2. A Cloud Function (see /functions/index.js) listens for new
///      `notifications` documents and sends a push: to the
///      'all_users' topic for broadcasts (targetUid == 'all'), or
///      directly to that user's saved fcmToken for personal ones.
///
/// Call [PushNotificationService.init] once, right after a user
/// lands on a home screen (Dashboard / Admin Dashboard) — calling
/// it before login would have no signed-in user to attach the
/// token to.
/// ============================================================
class PushNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      // iOS asks explicitly; Android <13 is implicit, Android 13+ also
      // needs this. Denying just means no push — the in-app notification
      // list still works either way, so this is safe to ignore failures.
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Every device listens to the same broadcast topic — simplest way
      // to fan out an urgent/event alert to everyone without looping
      // over every user's token from the client.
      await _messaging.subscribeToTopic('all_users');

      await _saveTokenForCurrentUser();
      _messaging.onTokenRefresh.listen((_) => _saveTokenForCurrentUser());
    } catch (_) {
      // Non-critical — push is a nice-to-have on top of in-app alerts.
    }
  }

  static Future<void> _saveTokenForCurrentUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final token = await _messaging.getToken();
    if (token == null) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).set(
      {'fcmToken': token},
      SetOptions(merge: true),
    );
  }

  /// Call on logout so the old token stops being tied to this account
  /// (best-effort — doesn't block sign-out if it fails).
  static Future<void> clearTokenOnLogout() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'fcmToken': FieldValue.delete()});
    } catch (_) {
      // Ignore — not worth blocking logout over.
    }
  }
}
