import 'package:cloud_firestore/cloud_firestore.dart';

/// ============================================================
/// DONOR MODEL
/// A lightweight read-model built from a `users` document,
/// used by FindDonorScreen (list + map). Carries a mutable
/// `distanceKm` so DonorService can sort/annotate results
/// relative to the searching user's current location.
/// ============================================================
class DonorModel {
  final String uid;
  final String fullName;
  final String bloodGroup;
  final String donorType;
  final String area;
  final String city;
  final String phone;
  final String profileImage;
  final bool isAvailable;
  final double? latitude;
  final double? longitude;
  double? distanceKm;

  DonorModel({
    required this.uid,
    required this.fullName,
    required this.bloodGroup,
    required this.donorType,
    required this.area,
    required this.city,
    required this.phone,
    required this.profileImage,
    this.isAvailable = true,
    this.latitude,
    this.longitude,
    this.distanceKm,
  });

  bool get hasLocation => latitude != null && longitude != null;

  String get location =>
      [area, city].where((s) => s.trim().isNotEmpty).join(', ');

  factory DonorModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return DonorModel(
      uid: doc.id,
      fullName: data['fullName'] ?? 'Unknown',
      bloodGroup: data['bloodGroup'] ?? '',
      donorType: data['donorType'] ?? 'None',
      area: data['area'] ?? '',
      city: data['city'] ?? '',
      phone: data['phone'] ?? '',
      profileImage: data['profileImage'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
    );
  }
}
