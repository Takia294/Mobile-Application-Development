import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/request_model.dart';

/// ============================================================
/// REQUEST DATABASE SERVICE
/// Handles all Firestore read/write operations for donation
/// requests. Used by EmergencyRequestScreen and MyRequestScreen.
/// ============================================================
class RequestDatabase {
  // ── Firestore references ──
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static CollectionReference<Map<String, dynamic>> get _requestsRef =>
      _db.collection('requests');

  static DocumentReference<Map<String, dynamic>> get _adminStatsRef =>
      _db.collection('admin_stats').doc('summary');

  // ─────────────────────────────────────────────────────────────
  //  STREAM MY REQUESTS  (real-time, auto-updates)
  //  Used by MyRequestScreen's StreamBuilder.
  //  Returns only the currently logged-in user's requests,
  //  ordered newest-first.
  // ─────────────────────────────────────────────────────────────
  static Stream<List<RequestModel>> streamMyRequests() {
    final uid = _auth.currentUser?.uid;

    // If no user is logged in, emit an empty list immediately.
    if (uid == null) {
      return Stream.value([]);
    }

    return _requestsRef
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => RequestModel.fromDoc(doc))
              .toList(),
        );
  }

  // ─────────────────────────────────────────────────────────────
  //  SUBMIT REQUEST
  //  Called by EmergencyRequestScreen when the user taps Submit.
  //  Reads the current user's profile from the `users` collection
  //  to denormalize name + phone into the request document.
  // ─────────────────────────────────────────────────────────────
  static Future<void> submitRequest({
    required String requestType,
    required String bloodGroup,
    required String organ,
    required String hospital,
    required String address,
    required String urgency,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    // ── Fetch user profile for denormalized fields ──
    String requesterName = '';
    String requesterPhone = '';

    try {
      final userDoc = await _db.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        requesterName = data['name'] ?? data['fullName'] ?? '';
        requesterPhone = data['phone'] ?? data['phoneNumber'] ?? '';
      }
    } catch (_) {
      // Non-critical: proceed even if profile fetch fails
    }

    final model = RequestModel(
      uid: user.uid,
      requestType: requestType,
      bloodGroup: bloodGroup,
      organ: organ,
      hospital: hospital,
      address: address,
      urgency: urgency,
      requesterName: requesterName,
      requesterPhone: requesterPhone,
      createdAt: Timestamp.now(),
      status: 'Active',
    );

    await _requestsRef.add(model.toMap());
  }

  // ─────────────────────────────────────────────────────────────
  //  UPDATE STATUS
  //  Called when the user taps "Mark as Complete".
  // ─────────────────────────────────────────────────────────────
  static Future<void> updateStatus({
    required String requestId,
    required String newStatus,
  }) async {
    if (requestId.isEmpty) throw Exception('Invalid request ID');

    await _requestsRef.doc(requestId).update({'status': newStatus});
  }

  // ─────────────────────────────────────────────────────────────
  //  INCREMENT TODAY'S DONATIONS  (admin stats counter)
  //  Uses FieldValue.increment so it's safe under concurrent
  //  writes — no read-modify-write race condition.
  // ─────────────────────────────────────────────────────────────
  static Future<void> incrementTodaysDonations() async {
    await _adminStatsRef.set(
      {'todaysDonations': FieldValue.increment(1)},
      SetOptions(merge: true),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  STREAM ALL REQUESTS  (admin use — all users)
  // ─────────────────────────────────────────────────────────────
  static Stream<List<RequestModel>> streamAllRequests() {
    return _requestsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => RequestModel.fromDoc(doc))
              .toList(),
        );
  }

  // ─────────────────────────────────────────────────────────────
  //  STREAM TODAY'S DONATION COUNT  (admin stat card)
  //  Listens to the same admin_stats/summary document that
  //  incrementTodaysDonations() writes to, so the Admin Dashboard
  //  stat card updates live whenever a request is fulfilled.
  // ─────────────────────────────────────────────────────────────
  static Stream<int> streamTodaysDonationCount() {
    return _adminStatsRef.snapshots().map((doc) {
      if (!doc.exists) return 0;
      final data = doc.data() as Map<String, dynamic>? ?? {};
      return (data['todaysDonations'] as num?)?.toInt() ?? 0;
    });
  }

  // ─────────────────────────────────────────────────────────────
  //  DELETE REQUEST  (admin use)
  //  Permanently removes a request document from Firestore.
  // ─────────────────────────────────────────────────────────────
  static Future<void> deleteRequest(String requestId) async {
    if (requestId.isEmpty) throw Exception('Invalid request ID');
    await _requestsRef.doc(requestId).delete();
  }
}