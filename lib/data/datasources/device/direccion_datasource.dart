import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';

import '../../../domain/repositories/direccion_repository.dart';

/// Geocodificación inversa del teléfono con `geocoding`. Sin red o sin resultado devuelve `null`.
class DireccionDataSource implements DireccionRepository {
  DireccionDataSource({this._geocoding});

  /// Se crea en el primer uso: el plugin solo existe en el teléfono, no en las pruebas.
  Geocoding? _geocoding;

  @override
  Future<String?> direccion(double latitud, double longitud) async {
    try {
      final geocoding = _geocoding ??= Geocoding(locale: const Locale('es', 'MX'));
      final lugares = await geocoding.placemarkFromCoordinates(latitud, longitud);
      if (lugares.isEmpty) return null;
      return formatear(lugares.first);
    } catch (e) {
      debugPrint('[FixFlow] No se pudo calcular la dirección: $e');
      return null;
    }
  }

  /// «Calle Morelos 892, Centro». Si no hay calle, usa lo que haya de colonia o ciudad.
  @visibleForTesting
  static String? formatear(Placemark p) {
    String? limpio(String? s) => (s == null || s.trim().isEmpty) ? null : s.trim();

    final calle = limpio([limpio(p.thoroughfare), limpio(p.subThoroughfare)].whereType<String>().join(' '));
    final partes = [calle ?? limpio(p.street), limpio(p.subLocality) ?? limpio(p.locality)].whereType<String>();
    return partes.isEmpty ? null : partes.join(', ');
  }
}
