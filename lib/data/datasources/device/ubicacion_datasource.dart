import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../../domain/entities/coordenada.dart';
import '../../../domain/repositories/ubicacion_repository.dart';

/// GPS real con `geolocator`. Pide el permiso si todavía no se ha decidido.
class UbicacionDataSource implements UbicacionRepository {
  @override
  Future<Coordenada?> posicionActual() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied || permiso == LocationPermission.deniedForever) return null;

      final posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(timeLimit: Duration(seconds: 10)),
      );
      return Coordenada(posicion.latitude, posicion.longitude);
    } catch (e) {
      debugPrint('[FixFlow] No se pudo leer el GPS: $e');
      return null;
    }
  }
}
