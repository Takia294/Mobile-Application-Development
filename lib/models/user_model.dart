import 'package:cloud_firestore/cloud_firestore.dart';

/// ============================================================
/// USER MODEL
/// Represents a document in the `users` collection.
/// Used across profile, dashboard, and donor-search features so
/// every screen reads/writes the exact same field names.
///
/// IMPORTANT: `donorType` uses the canonical values below — every
/// screen in the app must use these exact strings or Firestore
/// queries that filter on donorType will silently return nothing.
///   'Blood Donor' | 'Organ Donor' | 'Both' | 'None'
/// ============================================================
class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String house;
  final String road;
  final String area;
  final String city;
  final String gender;
  final String dob;
  final String bloodGroup; // 'A+', 'A-', ... or '' if not set
  final String donorType; // 'Blood Donor' | 'Organ Donor' | 'Both' | 'None'
  final String profileImage;
  final String certificateImage;
<<<<<<< HEAD
  // 'none' | 'pending' | 'verified' | 'rejected' — set to 'pending' whenever
  // a donor (re)uploads a certificate; reviewed by an admin.
  final String certificateStatus;
  // Whether this donor currently wants to be shown in donor search/map.
  // Lets a donor temporarily hide themselves (e.g. sick, traveling)
  // without losing their saved donor type / blood group.
  final bool isAvailable;
=======
>>>>>>> main
  final String role; // 'user' | 'admin'
  final double? latitude;
  final double? longitude;
  final Timestamp? locationUpdatedAt;
<<<<<<< HEAD
  final String? fcmToken; // for push notifications (see PushNotificationService)
=======
>>>>>>> main
  final Timestamp createdAt;

  const UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    this.house = '',
    this.road = '',
    this.area = '',
    this.city = '',
    this.gender = '',
    this.dob = '',
    this.bloodGroup = '',
    this.donorType = 'None',
    this.profileImage = '',
    this.certificateImage = '',
<<<<<<< HEAD
    this.certificateStatus = 'none',
    this.isAvailable = true,
=======
>>>>>>> main
    this.role = 'user',
    this.latitude,
    this.longitude,
    this.locationUpdatedAt,
<<<<<<< HEAD
    this.fcmToken,
=======
>>>>>>> main
    required this.createdAt,
  });

  /// Whether this user is currently a discoverable donor.
  bool get isActiveDonor => donorType != 'None' && donorType.isNotEmpty;

  /// Whether this user has shared a live location for the map.
  bool get hasLocation => latitude != null && longitude != null;

  String get fullAddress {
    final parts = [house, road, area, city].where((s) => s.trim().isNotEmpty);
    return parts.join(', ');
  }

  factory UserModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: doc.id,
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      house: data['house'] ?? '',
      road: data['road'] ?? '',
      area: data['area'] ?? '',
      city: data['city'] ?? '',
      gender: data['gender'] ?? '',
      dob: data['dob'] ?? '',
      bloodGroup: data['bloodGroup'] ?? '',
      donorType: (data['donorType'] == null || data['donorType'] == '')
          ? 'None'
          : data['donorType'],
      profileImage: data['profileImage'] ?? '',
      certificateImage: data['certificateImage'] ?? '',
<<<<<<< HEAD
      certificateStatus: data['certificateStatus'] ?? 'none',
      isAvailable: data['isAvailable'] ?? true,
=======
>>>>>>> main
      role: data['role'] ?? 'user',
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      locationUpdatedAt: data['locationUpdatedAt'] is Timestamp
          ? data['locationUpdatedAt']
          : null,
<<<<<<< HEAD
      fcmToken: data['fcmToken'] as String?,
=======
>>>>>>> main
      createdAt:
          data['createdAt'] is Timestamp ? data['createdAt'] : Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'house': house,
      'road': road,
      'area': area,
      'city': city,
      'gender': gender,
      'dob': dob,
      'bloodGroup': bloodGroup,
      'donorType': donorType,
      'profileImage': profileImage,
      'certificateImage': certificateImage,
<<<<<<< HEAD
      'certificateStatus': certificateStatus,
      'isAvailable': isAvailable,
=======
>>>>>>> main
      'role': role,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (locationUpdatedAt != null) 'locationUpdatedAt': locationUpdatedAt,
<<<<<<< HEAD
      if (fcmToken != null) 'fcmToken': fcmToken,
=======
>>>>>>> main
      'createdAt': createdAt,
    };
  }
}
