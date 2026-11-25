import 'package:geolocator/geolocator.dart';

import '../../../core/log/bitacora.dart';
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
      return Coordenada(posicion.latitude, posicion.longitude, precision: posicion.accuracy);
    } catch (e) {
      Bitacora.error('No se pudo leer el GPS', e);
      return null;
    }
  }
}
