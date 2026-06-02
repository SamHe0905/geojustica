import 'dart:async';
import 'dart:math' as math;
// ignore: avoid_web_libraries_in_flutter
import 'dart:js_util' as js_util;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:latlong2/latlong.dart';

class LocationService {
  static const LatLng campoGrandeCenter = LatLng(-20.4697, -54.6201);

  /// Solicita a localização do usuário via Web Geolocation API.
  /// Retorna null se o usuário negar ou ocorrer erro.
  Future<LatLng?> getCurrentLocation() async {
    try {
      if (!js_util.hasProperty(html.window.navigator, 'geolocation')) {
        return null;
      }

      final completer = Completer<LatLng?>();
      final geolocation = js_util.getProperty(html.window.navigator, 'geolocation');

      js_util.callMethod(geolocation, 'getCurrentPosition', [
        js_util.allowInterop((position) {
          try {
            final coords = js_util.getProperty(position, 'coords');
            final lat = (js_util.getProperty(coords, 'latitude') as num).toDouble();
            final lng = (js_util.getProperty(coords, 'longitude') as num).toDouble();
            if (!completer.isCompleted) {
              completer.complete(LatLng(lat, lng));
            }
          } catch (_) {
            if (!completer.isCompleted) completer.complete(null);
          }
        }),
        js_util.allowInterop((error) {
          if (!completer.isCompleted) completer.complete(null);
        }),
        js_util.jsify({
          'enableHighAccuracy': false,
          'timeout': 10000,
          'maximumAge': 60000,
        }),
      ]);

      return await completer.future.timeout(
        const Duration(seconds: 12),
        onTimeout: () => null,
      );
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
