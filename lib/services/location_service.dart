import 'dart:async';
import 'dart:math' as math;
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'package:latlong2/latlong.dart';

class LocationService {
  static const LatLng campoGrandeCenter = LatLng(-20.4697, -54.6201);

  /// Solicita a localização do usuário via Web Geolocation API.
  Future<LatLng?> getCurrentLocation() async {
    try {
      final geolocation = html.window.navigator.geolocation;
      final position = await geolocation
          .getCurrentPosition(
            enableHighAccuracy: false,
            timeout: const Duration(seconds: 10),
            maximumAge: const Duration(minutes: 1),
          )
          .timeout(const Duration(seconds: 12));

      final coords = position.coords;
      if (coords == null) return null;
      final lat = coords.latitude?.toDouble();
      final lng = coords.longitude?.toDouble();
      if (lat == null || lng == null) return null;
      return LatLng(lat, lng);
    } catch (_) {
      return null;
    }
  }

  double calculateDistanceKm(LatLng from, LatLng to) {
    const earthRadius = 6371.0;
    final dLat = _toRad(to.latitude - from.latitude);
    final dLon = _toRad(to.longitude - from.longitude);
    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(_toRad(from.latitude)) *
            math.cos(_toRad(to.latitude)) *
            math.pow(math.sin(dLon / 2), 2);
    final c = 2 * math.asin(math.sqrt(a.toDouble()));
    return earthRadius * c;
  }

  String formatDistance(double km) {
    if (km < 1) return '${(km * 1000).round()} m';
    return '${km.toStringAsFixed(1)} km';
  }

  double _toRad(double deg) => deg * math.pi / 180;
}
