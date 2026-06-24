import 'package:cloud_firestore/cloud_firestore.dart';

/// ============================================================
/// REQUEST MODEL
/// Represents a single Blood / Organ donation request that is
/// saved into the `requests` collection in Firestore and read
/// live by both the user app and the Admin Dashboard.
///
/// `status` is what the Admin Dashboard's "Active Request" stat
/// card counts — any request saved with status = 'Active' will
/// immediately be included in that live count.
/// ============================================================
class RequestModel {
  final String id; // Firestore document id (empty until saved)
  final String uid; // uid of the user who created the request
  final String requestType; // 'Blood Donation' | 'Organ Donation'
  final String bloodGroup; // e.g. 'A+', 'O-', 'None'
  final String organ; // e.g. 'Kidney', 'None' (only for Organ Donation)
  final String hospital; // selected hospital name
  final String address; // free text address
  final String urgency; // 'Low' | 'Medium' | 'High' | 'Critical'
  final String status; // 'Active' | 'Pending' | 'Critical' | 'Fulfilled'
  final String requesterName; // full name (denormalized for fast admin display)
  final String requesterPhone; // phone (denormalized for fast admin display)
  final Timestamp createdAt;

  const RequestModel({
    this.id = '',
    required this.uid,
    required this.requestType,
    required this.bloodGroup,
    required this.organ,
    required this.hospital,
    required this.address,
    required this.urgency,
    required this.requesterName,
    required this.requesterPhone,
    required this.createdAt,
    this.status = 'Active',
  });

  /// ── Convert this model into a Map ready to be written to Firestore ──
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'requestType': requestType,
      'bloodGroup': bloodGroup,
      'organType': organ,
      'hospital': hospital,
      'address': address,
      'urgency': urgency,
      'status': status,
      'requesterName': requesterName,
      'requesterPhone': requesterPhone,
      'createdAt': createdAt,
    };
  }

  /// ── Build a model instance from a Firestore document ──
  factory RequestModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return RequestModel(
      id: doc.id,
      uid: data['uid'] ?? '',
      requestType: data['requestType'] ?? 'Blood Donation',
      bloodGroup: data['bloodGroup'] ?? 'None',
      organ: data['organType'] ?? 'None',
      hospital: data['hospital'] ?? 'None',
      address: data['address'] ?? '',
      urgency: data['urgency'] ?? 'Medium',
      status: data['status'] ?? 'Active',
      requesterName: data['requesterName'] ?? '',
      requesterPhone: data['requesterPhone'] ?? '',
      createdAt:
          data['createdAt'] is Timestamp ? data['createdAt'] : Timestamp.now(),
    );
  }

  /// ── Convenience copyWith (useful when updating status locally) ──
  RequestModel copyWith({String? status}) {
    return RequestModel(
      id: id,
      uid: uid,
      requestType: requestType,
      bloodGroup: bloodGroup,
      organ: organ,
      hospital: hospital,
      address: address,
      urgency: urgency,
      status: status ?? this.status,
      requesterName: requesterName,
      requesterPhone: requesterPhone,
      createdAt: createdAt,
    );
  }
}