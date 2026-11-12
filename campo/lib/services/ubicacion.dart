import 'package:geolocator/geolocator.dart';

/// Ubicación del teléfono para check-in, check-out y asistencia.
class Ubicacion {
  static Future<Map<String, double>?> actual() async {
    try {
      final habilitada = await Geolocator.isLocationServiceEnabled();
      if (!habilitada) return null;

      var permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }
      if (permiso == LocationPermission.denied ||
          permiso == LocationPermission.deniedForever) {
        return null;
      }

      final posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 25),
        ),
      );
      return {
        'lat': posicion.latitude,
        'lng': posicion.longitude,
        'precision': posicion.accuracy,
      };
    } catch (_) {
      return null;
    }
  }
}