import 'package:geolocator/geolocator.dart';

/// ============================================================
/// LOCATION SERVICE
/// Wraps `geolocator` (free, no API key needed) to get the
/// device's current GPS position and to compute distances
/// between two coordinates. Used by:
///   - RegistrationScreen / MyProfileScreen: to save the donor's
///     coordinates into Firestore (`latitude`, `longitude`).
///   - FindDonorScreen: to get the searcher's current position
///     and sort/filter donors by real distance on the free
///     OpenStreetMap-based map (see MapService / flutter_map).
/// ============================================================
class LocationService {
  /// Ensures location services are on and permission is granted,
  /// then returns the current position. Throws a
  /// [LocationServiceException] on failure (services off, permission
  /// denied, etc.) — it never returns null, so callers don't need to
  /// null-check `pos.latitude` / `pos.longitude`.
  static Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceException(
          'Location services are disabled. Please enable GPS.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationServiceException('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationServiceException(
          'Location permission permanently denied. Enable it from app settings.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Distance in kilometers between two lat/lng points.
  static double distanceInKm({
    required double lat1,
    required double lng1,
    required double lat2,
    required double lng2,
  }) {
    final meters = Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
    return meters / 1000;
  }

  static String formatDistance(double? km) {
    if (km == null) return '';
    if (km < 1) return '${(km * 1000).round()} m away';
    return '${km.toStringAsFixed(1)} km away';
  }
}

class LocationServiceException implements Exception {
  final String message;
  LocationServiceException(this.message);
  @override
  String toString() => message;
}
