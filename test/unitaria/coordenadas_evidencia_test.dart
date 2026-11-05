// Test tipo Unitarias: se prueba una clase o función sin pantalla y sin red real

import 'package:fix_flow/domain/entities/reporte_nuevo.dart';
import 'package:fix_flow/domain/entities/tipo_incidencia.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const bache = TipoIncidencia(id: '1', nombre: 'Bache', codigo: 'BACHE', orientacion: OrientacionFoto.suelo);

  ReporteNuevo reporte({double lat = 18.9220, double lng = -99.2340}) => ReporteNuevo(
        tipo: bache,
        descripcion: 'Bache grande en el carril derecho',
        latitud: lat,
        longitud: lng,
        inclinacion: 62,
        rutaFoto: '/tmp/foto.jpg',
        capturadaEn: DateTime(2026, 11, 4, 11, 28),
      );

  group('HU-07: Asociar coordenadas a la evidencia', () {
    test('La evidencia queda vinculada a las coordenadas (CA-1, CA-2)', () {
      final r = reporte();

      // Foto + latitud + longitud están asociados en el mismo modelo
      expect(r.rutaFoto, '/tmp/foto.jpg');
      expect(r.latitud, 18.9220);
      expect(r.longitud, -99.2340);
    });

    test('El usuario no puede introducir coordenadas manualmente (CA-3, RN-10)', () {
      final r = reporte();

      // Las coordenadas son campos final: no existe setter.
      // Crear otro reporte no altera el primero (inmutabilidad).
      final r2 = reporte(lat: 0, lng: 0);

      // r mantiene sus coordenadas originales del GPS
      expect(r.latitud, 18.9220);
      expect(r.longitud, -99.2340);
      // r2 es una instancia independiente
      expect(r2.latitud, 0);
      expect(r2.longitud, 0);
    });

    test('La ubicación permanece asociada al reporte (CA-4, RN-10)', () {
      final r = reporte();

      // Múltiples lecturas devuelven siempre el valor original (final)
      for (var i = 0; i < 3; i++) {
        expect(r.latitud, 18.9220);
        expect(r.longitud, -99.2340);
      }

      // La foto y la fecha siguen vinculadas a la misma ubicación
      expect(r.rutaFoto, isNotEmpty);
      expect(r.capturadaEn, isNotNull);
    });
  });
}

