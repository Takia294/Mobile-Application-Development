import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/request_model.dart';

/// ============================================================
/// REQUEST DATABASE
/// Single place that talks to the `requests` collection in
/// Firestore. Both the user app (EmergencyRequestScreen,
/// MyRequestScreen) and the Admin Dashboard should go through
/// this class instead of calling FirebaseFirestore directly.
/// ============================================================
class RequestDatabase {
  RequestDatabase._(); // prevent instantiation, use static methods

  static final CollectionReference _requestsRef =
      FirebaseFirestore.instance.collection('requests');

  // ────────────────────────────────────────────
  // CREATE — Submit a new emergency request
  // ────────────────────────────────────────────
  static Future<void> submitRequest({
    required String requestType,
    required String bloodGroup,
    required String organ,
    required String hospital,
    required String address,
    required String urgency,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('You must be logged in to submit a request');
    }

    String requesterName = '';
    String requesterPhone = '';
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        requesterName = data['fullName'] ?? '';
        requesterPhone = data['phone'] ?? '';
      }
    } catch (_) {}

    final request = RequestModel(
      uid: user.uid,
      requestType: requestType,
      bloodGroup: bloodGroup,
      organ: organ,
      hospital: hospital,
      address: address,
      urgency: urgency,
      requesterName: requesterName,
      requesterPhone: requesterPhone,
      status: 'Active',
      createdAt: Timestamp.now(),
    );

    await _requestsRef.add(request.toMap());
  }

  // ────────────────────────────────────────────
  // READ — Live stream of ALL requests (Admin Dashboard)
  // ────────────────────────────────────────────
  static Stream<List<RequestModel>> streamAllRequests() {
    return _requestsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => RequestModel.fromDoc(d)).toList());
  }

  // ────────────────────────────────────────────
  // READ — Live stream of only Active requests
  // ────────────────────────────────────────────
  static Stream<List<RequestModel>> streamActiveRequests() {
    return _requestsRef
        .where('status', isEqualTo: 'Active')
        .snapshots()
        .map((snap) => snap.docs.map((d) => RequestModel.fromDoc(d)).toList());
  }

  // ────────────────────────────────────────────
  // READ — Live stream of current user's requests
  // ────────────────────────────────────────────
  static Stream<List<RequestModel>> streamMyRequests() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _requestsRef
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => RequestModel.fromDoc(d)).toList());
  }

  // ────────────────────────────────────────────
  // READ — Get a single request once (not live)
  // ────────────────────────────────────────────
  static Future<RequestModel?> getRequestById(String requestId) async {
    final doc = await _requestsRef.doc(requestId).get();
    if (!doc.exists) return null;
    return RequestModel.fromDoc(doc);
  }

  // ────────────────────────────────────────────
  // UPDATE — Change request status
  // ────────────────────────────────────────────
  static Future<void> updateStatus({
    required String requestId,
    required String newStatus,
  }) async {
    await _requestsRef.doc(requestId).update({'status': newStatus});
  }

  // ────────────────────────────────────────────
  // UPDATE — Edit full request details
  // ────────────────────────────────────────────
  static Future<void> updateRequest({
    required String requestId,
    required Map<String, dynamic> updatedFields,
  }) async {
    await _requestsRef.doc(requestId).update(updatedFields);
  }

  // ────────────────────────────────────────────
  // DELETE — Remove a request
  // ────────────────────────────────────────────
  static Future<void> deleteRequest(String requestId) async {
    await _requestsRef.doc(requestId).delete();
  }

  // ────────────────────────────────────────────
  // COUNT — One-time count of Active requests
  // ────────────────────────────────────────────
  static Future<int> getActiveRequestCount() async {
    final snap =
        await _requestsRef.where('status', isEqualTo: 'Active').get();
    return snap.docs.length;
  }

  // ════════════════════════════════════════════
  // TODAY'S DONATIONS — Admin Dashboard counter
  // ════════════════════════════════════════════

  /// Today's date key — e.g. "2026-06-17"
  static String get _todayKey =>
      DateTime.now().toIso8601String().substring(0, 10);

  /// Reference to today's stats document in Firestore:
  /// admin_stats/daily_donations/days/{YYYY-MM-DD}
  static DocumentReference get _todayStatsDoc =>
      FirebaseFirestore.instance
          .collection('admin_stats')
          .doc('daily_donations')
          .collection('days')
          .doc(_todayKey);

  /// Call this when a request is marked as Fulfilled.
  /// Creates the doc if it doesn't exist yet (merge: true).
  static Future<void> incrementTodaysDonations() async {
    await _todayStatsDoc.set(
      {
        'count': FieldValue.increment(1),
        'date': _todayKey,
        'lastUpdated': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Live stream of today's fulfilled donation count.
  /// Use this in the Admin Dashboard stat card.
  static Stream<int> streamTodaysDonationCount() {
    return _todayStatsDoc.snapshots().map((snap) {
      if (!snap.exists) return 0;
      return (snap.data() as Map<String, dynamic>)['count'] as int? ?? 0;
    });
  }
}