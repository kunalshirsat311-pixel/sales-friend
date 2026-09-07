import 'package:geolocator/geolocator.dart';

class LocationService {
  // ─── GET CURRENT LOCATION ────────────────────────────────────
  Future<Position?> getCurrentLocation() async {
    try {
      // Step 1: Check if location services are enabled on phone
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // Step 2: Check permission status
      LocationPermission permission = await Geolocator.checkPermission();

      // Step 3: If permission not given yet, ask for it
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null; // User said no
        }
      }

      // Step 4: If permanently denied, we cannot ask again
      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      // Step 5: All good — get the actual GPS position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return position;
    } catch (e) {
      return null;
    }
  }

  // ─── FORMAT LOCATION AS READABLE TEXT ───────────────────────
  String formatLocation(Position position) {
    // Round to 4 decimal places for clean display
    String lat = position.latitude.toStringAsFixed(4);
    String lng = position.longitude.toStringAsFixed(4);
    return 'Lat: $lat, Lng: $lng';
  }

  // ─── GET LOCATION STATUS MESSAGE ────────────────────────────
  Future<String> getLocationStatus() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return 'Location services are disabled. Please enable GPS.';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      return 'Location permission denied.';
    }
    if (permission == LocationPermission.deniedForever) {
      return 'Location permission permanently denied. Please enable in phone settings.';
    }

    return 'Location ready';
  }
}
