/// ============================================================
/// HOSPITAL MODEL
/// Static reference data for major Bangladeshi hospitals, with
/// real coordinates so the app can compute distance and plot
/// them on the free OpenStreetMap-based map. Backed by
/// HospitalService, which is the single source of truth used by
/// EmergencyRequestScreen (hospital picker) and DashboardScreen
/// (nearby hospitals) — no more duplicated hardcoded lists.
/// ============================================================
class HospitalModel {
  final String name;
  final String city;
  final double latitude;
  final double longitude;

  const HospitalModel({
    required this.name,
    required this.city,
    required this.latitude,
    required this.longitude,
  });

  String get displayName => '$name - $city';
}
