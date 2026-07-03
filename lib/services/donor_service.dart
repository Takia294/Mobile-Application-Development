import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/donor_model.dart';
import 'location_service.dart';

/// ============================================================
/// DONOR SERVICE
/// Single source of truth for querying donors from the `users`
/// collection. Fixes the original bug where FindDonorScreen
/// filtered on donorType values ('Blood', 'Organ', 'Both') that
/// never matched what MyProfileScreen actually saves
/// ('Blood Donor', 'Organ Donor', 'Both', 'None') — donors never
/// showed up. This service is now the only place donorType
/// values are interpreted, so both screens stay in sync.
/// ============================================================
class DonorService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Canonical donor-type values as actually stored in Firestore.
  static const String bloodDonor = 'Blood Donor';
  static const String organDonor = 'Organ Donor';
  static const String bothDonor = 'Both';
  static const String noneDonor = 'None';

  /// Which donorType values count as "a blood donor" (also 'Both').
  static const List<String> bloodDonorTypes = [bloodDonor, bothDonor];

  /// Which donorType values count as "an organ donor" (also 'Both').
  static const List<String> organDonorTypes = [organDonor, bothDonor];

  /// Live stream of donors, optionally filtered by blood group.
  /// Excludes the current logged-in user from their own search.
  static Stream<List<DonorModel>> streamDonors({String? bloodGroup}) {
    Query<Map<String, dynamic>> q = _db
        .collection('users')
        .where('donorType', whereIn: [bloodDonor, organDonor, bothDonor]);

    if (bloodGroup != null && bloodGroup != 'All') {
      q = q.where('bloodGroup', isEqualTo: bloodGroup);
    }

    return q.snapshots().map((snap) {
      final myUid = FirebaseAuth.instance.currentUser?.uid;
      return snap.docs
          .map((d) => DonorModel.fromDoc(d))
          .where((donor) => donor.uid != myUid)
          .toList();
    });
  }

  /// Annotates each donor with distance from [fromLat]/[fromLng]
  /// and sorts nearest-first. Donors without saved coordinates are
  /// pushed to the end (distanceKm stays null).
  static List<DonorModel> sortByDistance(
    List<DonorModel> donors, {
    required double fromLat,
    required double fromLng,
  }) {
    for (final donor in donors) {
      if (donor.hasLocation) {
        donor.distanceKm = LocationService.distanceInKm(
          lat1: fromLat,
          lng1: fromLng,
          lat2: donor.latitude!,
          lng2: donor.longitude!,
        );
      }
    }

    donors.sort((a, b) {
      if (a.distanceKm == null && b.distanceKm == null) return 0;
      if (a.distanceKm == null) return 1;
      if (b.distanceKm == null) return -1;
      return a.distanceKm!.compareTo(b.distanceKm!);
    });

    return donors;
  }
}
