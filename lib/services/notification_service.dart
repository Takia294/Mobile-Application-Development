import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/notification_model.dart';

/// ============================================================
/// NOTIFICATION SERVICE
/// Backs NotificationScreen with live Firestore data instead of
/// the previous hardcoded list. Reads documents from the
/// `notifications` collection that are either targeted directly
/// at the current user, or broadcast to everyone (targetUid=='all').
/// ============================================================
class NotificationService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static CollectionReference<Map<String, dynamic>> get _ref =>
      _db.collection('notifications');

  /// Live stream of notifications relevant to the current user,
  /// newest first. Combines personal + broadcast notifications.
  static Stream<List<NotificationModel>> streamMyNotifications() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    return _ref
        .where('targetUid', whereIn: [uid, 'all'])
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => NotificationModel.fromDoc(d)).toList());
  }

  static Future<void> markAsRead(String notificationId) async {
    await _ref.doc(notificationId).update({'isRead': true});
  }

  static Future<void> markAllAsRead(List<NotificationModel> items) async {
    final batch = _db.batch();
    for (final n in items.where((n) => !n.isRead)) {
      batch.update(_ref.doc(n.id), {'isRead': true});
    }
    await batch.commit();
  }

  /// Sends a broadcast notification to all users. Used by the
  /// Admin Dashboard (e.g. urgent blood requests, donor events).
  static Future<void> sendBroadcast({
    required String type,
    required String title,
    String subtitle = '',
    String buttonText = '',
  }) async {
    await _ref.add(NotificationModel(
      targetUid: 'all',
      type: type,
      title: title,
      subtitle: subtitle,
      buttonText: buttonText,
      createdAt: Timestamp.now(),
    ).toMap());
  }

  /// Sends a personal notification to one user (e.g. "your request
  /// was fulfilled"). Used by RequestDatabase when status changes.
  static Future<void> sendToUser({
    required String uid,
    required String type,
    required String title,
    String subtitle = '',
  }) async {
    await _ref.add(NotificationModel(
      targetUid: uid,
      type: type,
      title: title,
      subtitle: subtitle,
      createdAt: Timestamp.now(),
    ).toMap());
  }
}
