import '../models/hospital_model.dart';
import 'location_service.dart';

/// ============================================================
/// HOSPITAL SERVICE
/// Provides the master hospital list (with real coordinates) used
/// by EmergencyRequestScreen's hospital picker and DashboardScreen's
/// "Nearby Hospital" section, replacing the two separate hardcoded
/// lists that previously existed (and could drift out of sync).
/// ============================================================
class HospitalService {
  static const List<HospitalModel> hospitals = [
    HospitalModel(
      name: 'Dhaka Medical College Hospital',
      city: 'Dhaka',
      latitude: 23.7256,
      longitude: 90.3982,
    ),
    HospitalModel(
      name: 'Square Hospital',
      city: 'Dhaka',
      latitude: 23.7529,
      longitude: 90.3838,
    ),
    HospitalModel(
      name: 'Evercare Hospital',
      city: 'Dhaka',
      latitude: 23.8103,
      longitude: 90.4125,
    ),
    HospitalModel(
      name: 'United Hospital',
      city: 'Dhaka',
      latitude: 23.7935,
      longitude: 90.4148,
    ),
    HospitalModel(
      name: 'Bangabandhu Sheikh Mujib Medical University',
      city: 'Dhaka',
      latitude: 23.7383,
      longitude: 90.3958,
    ),
    HospitalModel(
      name: 'National Institute of Kidney Diseases',
      city: 'Dhaka',
      latitude: 23.7772,
      longitude: 90.3695,
    ),
    HospitalModel(
      name: 'Chittagong Medical College Hospital',
      city: 'Chattogram',
      latitude: 22.3667,
      longitude: 91.8317,
    ),
    HospitalModel(
      name: 'Rajshahi Medical College Hospital',
      city: 'Rajshahi',
      latitude: 24.3745,
      longitude: 88.6042,
    ),
    HospitalModel(
      name: 'Khulna Medical College Hospital',
      city: 'Khulna',
      latitude: 22.8087,
      longitude: 89.5560,
    ),
    HospitalModel(
      name: 'Sylhet MAG Osmani Medical College Hospital',
      city: 'Sylhet',
      latitude: 24.8998,
      longitude: 91.8484,
    ),
    HospitalModel(
      name: 'Mymensingh Medical College Hospital',
      city: 'Mymensingh',
      latitude: 24.7539,
      longitude: 90.4074,
    ),
    HospitalModel(
      name: 'Rangpur Medical College Hospital',
      city: 'Rangpur',
      latitude: 25.7558,
      longitude: 89.2444,
    ),
    HospitalModel(
      name: 'Sher-E-Bangla Medical College Hospital',
      city: 'Barishal',
      latitude: 22.7010,
      longitude: 90.3535,
    ),
    HospitalModel(
      name: 'Cumilla Medical College Hospital',
      city: 'Cumilla',
      latitude: 23.4607,
      longitude: 91.1809,
    ),
  ];

  static List<String> get displayNames =>
      hospitals.map((h) => h.displayName).toList();

  /// Nearest hospitals to a given coordinate, closest first.
  static List<MapEntry<HospitalModel, double>> nearestTo({
    required double latitude,
    required double longitude,
    int limit = 5,
  }) {
    final withDistance = hospitals.map((h) {
      final km = LocationService.distanceInKm(
        lat1: latitude,
        lng1: longitude,
        lat2: h.latitude,
        lng2: h.longitude,
      );
      return MapEntry(h, km);
    }).toList();

    withDistance.sort((a, b) => a.value.compareTo(b.value));
    return withDistance.take(limit).toList();
  }
}
