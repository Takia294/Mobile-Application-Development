import 'package:cloud_firestore/cloud_firestore.dart';

/// ============================================================
/// NOTIFICATION MODEL
/// Represents a document in the `notifications` collection.
/// Each user has notifications targeted either at their uid
/// directly (personal, e.g. "your request was fulfilled") or
/// broadcast to all users (targetUid == 'all', e.g. urgent
/// blood requests, donor meetups).
/// ============================================================
class NotificationModel {
  final String id;
  final String targetUid; // specific uid, or 'all' for broadcast
  final String type; // 'urgent' | 'fulfilled' | 'info' | 'event'
  final String title;
  final String subtitle;
  final String buttonText;
  final bool isRead;
  final Timestamp createdAt;

  const NotificationModel({
    this.id = '',
    required this.targetUid,
    required this.type,
    required this.title,
    this.subtitle = '',
    this.buttonText = '',
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return NotificationModel(
      id: doc.id,
      targetUid: data['targetUid'] ?? 'all',
      type: data['type'] ?? 'info',
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      buttonText: data['buttonText'] ?? '',
      isRead: data['isRead'] ?? false,
      createdAt:
          data['createdAt'] is Timestamp ? data['createdAt'] : Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'targetUid': targetUid,
      'type': type,
      'title': title,
      'subtitle': subtitle,
      'buttonText': buttonText,
      'isRead': isRead,
      'createdAt': createdAt,
    };
  }

  /// Human friendly "x ago" string without extra date packages.
  String get timeAgo {
    final diff = DateTime.now().difference(createdAt.toDate());
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}
