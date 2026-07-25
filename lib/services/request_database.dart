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
  //  SUBMIT COOLDOWN
  //  Minimum gap required between two requests from the SAME user.
  //  Prevents one account from spamming the urgent-broadcast alert
  //  (see NotificationService.sendBroadcast, called from
  //  EmergencyRequestScreen) to every donor over and over.
  //  NOTE: this is a client-side deterrent, not a hard security
  //  boundary — a modified/rooted client could skip this check.
  //  Real enforcement of "N requests per M minutes" belongs in a
  //  Cloud Function (App Check + a server-side counter), which is
  //  out of scope for the Flutter client alone.
  // ─────────────────────────────────────────────────────────────
  static const Duration submitCooldown = Duration(minutes: 5);

  /// Throws [RequestCooldownException] if the current user submitted
  /// a request more recently than [submitCooldown] allows. Called
  /// automatically by [submitRequest] — screens don't need to call
  /// this separately, just catch the exception.
  static Future<void> _assertNotOnCooldown(String uid) async {
    final recent = await _requestsRef
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (recent.docs.isEmpty) return;

    final lastCreatedAt = recent.docs.first.data()['createdAt'];
    if (lastCreatedAt is! Timestamp) return;

    final elapsed = DateTime.now().difference(lastCreatedAt.toDate());
    if (elapsed < submitCooldown) {
      throw RequestCooldownException(submitCooldown - elapsed);
    }
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

    await _assertNotOnCooldown(user.uid);

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

    // ── Notify matching, available donors ──
    // Every new request (not just High/Critical) alerts the donors who
    // could actually fulfill it: donors with a matching donor type who
    // haven't hidden themselves from search. Non-critical — if this
    // fails, the request itself is already saved successfully.
    try {
      await _notifyMatchingDonors(model);
    } catch (_) {}
  }

  // ─────────────────────────────────────────────────────────────
  //  NOTIFY MATCHING DONORS
  //  Queries `users` for available donors whose donorType matches the
  //  request (Blood Donor/Both for a blood request, Organ Donor/Both
  //  for an organ request), narrows to the exact blood group client-
  //  side (keeps the Firestore composite index to just isAvailable +
  //  donorType, reused by both request types), then writes one
  //  personal notification document per matching donor via a batch.
  //  The requester themselves is never notified about their own request.
  // ─────────────────────────────────────────────────────────────
  static Future<void> _notifyMatchingDonors(RequestModel model) async {
    final donorTypes = model.requestType == 'Organ Donation'
        ? const ['Organ Donor', 'Both']
        : const ['Blood Donor', 'Both'];

    final snap = await _db
        .collection('users')
        .where('isAvailable', isEqualTo: true)
        .where('donorType', whereIn: donorTypes)
        .get();

    final matchingDocs = snap.docs.where((doc) {
      if (doc.id == model.uid) return false; // don't notify the requester
      if (model.requestType == 'Organ Donation') return true;
      final donorBloodGroup = doc.data()['bloodGroup'] ?? '';
      return donorBloodGroup == model.bloodGroup;
    }).toList();

    if (matchingDocs.isEmpty) return;

    final title = model.requestType == 'Organ Donation'
        ? 'New ${model.organ} request nearby'
        : 'New ${model.bloodGroup} blood request nearby';
    final subtitle = '${model.hospital} • ${model.urgency} urgency';

    final batch = _db.batch();
    final notificationsRef = _db.collection('notifications');
    for (final doc in matchingDocs) {
      batch.set(notificationsRef.doc(), {
        'targetUid': doc.id,
        'type': 'urgent',
        'title': title,
        'subtitle': subtitle,
        'buttonText': 'Respond Now',
        'readBy': <String>[],
        'createdAt': Timestamp.now(),
      });
    }
    await batch.commit();
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
  //  [limit] bounds how many requests the Admin Dashboard reads at
  //  once — without it, a growing `requests` collection would mean
  //  every admin session re-downloads the entire history on every
  //  single write, which gets slow and expensive fast. 300 keeps
  //  the dashboard responsive; older requests are still reachable
  //  via a dedicated history/search screen if you build one later.
  // ─────────────────────────────────────────────────────────────
  static Stream<List<RequestModel>> streamAllRequests({int limit = 300}) {
    return _requestsRef
        .orderBy('createdAt', descending: true)
        .limit(limit)
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

/// Thrown by [RequestDatabase.submitRequest] when the current user is
/// still within [RequestDatabase.submitCooldown] of their last request.
/// Screens should catch this specifically to show a friendly
/// "please wait Xm" message instead of a generic error.
class RequestCooldownException implements Exception {
  final Duration remaining;
  RequestCooldownException(this.remaining);

  String get friendlyMessage {
    final mins = remaining.inSeconds / 60;
    if (mins < 1) {
      return 'Please wait a few seconds before submitting another request.';
    }
    return 'Please wait about ${mins.ceil()} minute(s) before submitting another request.';
  }

  @override
  String toString() => friendlyMessage;
}