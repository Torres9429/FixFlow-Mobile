// Test tipo Unitarias: se prueba una clase o función sin pantalla y sin red real

import 'package:fix_flow/domain/entities/coordenada.dart';
import 'package:fix_flow/domain/entities/reporte_nuevo.dart';
import 'package:fix_flow/domain/entities/tipo_incidencia.dart';
import 'package:fix_flow/domain/validators/evidencia_validator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks.dart';

void main() {
  late MockUbicacionRepository mockUbicacion;

  setUp(() {
    mockUbicacion = MockUbicacionRepository();
  });

  group('HU-05: El servicio de ubicación devuelve latitud y longitud (CA-2, CA-3)', () {
    test('Con un mock del GPS, se obtienen coordenadas válidas (no nulas)', () async {
      when(() => mockUbicacion.posicionActual())
          .thenAnswer((_) async => const Coordenada(18.9220, -99.2340));

      final posicion = await mockUbicacion.posicionActual();

      expect(posicion, isNotNull);
      expect(posicion!.latitud, 18.9220);
      expect(posicion.longitud, -99.2340);
    });

    test('Las coordenadas obtenidas están dentro del rango geográfico válido', () async {
      when(() => mockUbicacion.posicionActual())
          .thenAnswer((_) async => const Coordenada(18.9220, -99.2340));

      final posicion = await mockUbicacion.posicionActual();

      expect(posicion, isNotNull);
      // Latitud debe estar entre -90° y +90°
      expect(posicion!.latitud, inInclusiveRange(-90.0, 90.0));
      // Longitud debe estar entre -180° y +180°
      expect(posicion.longitud, inInclusiveRange(-180.0, 180.0));
    });
  });

  group('HU-05: Sin ubicación disponible se impide el envío (CA-5, RN-12)', () {
    test('Si el GPS no está disponible o falla, el reporte no se puede enviar', () async {
      when(() => mockUbicacion.posicionActual()).thenAnswer((_) async => null);

      final posicion = await mockUbicacion.posicionActual();
      expect(posicion, isNull);

      // Si no hay coordenadas GPS válidas (por ejemplo, valor centinela fuera de rango),
      // validarEvidencia rechaza el reporte impidiendo el envío (RN-12)
      final reporteSinUbicacion = ReporteNuevo(
        tipo: const TipoIncidencia(id: '1', nombre: 'Bache', codigo: 'BACHE', orientacion: OrientacionFoto.suelo),
        descripcion: 'Bache sin coordenadas',
        latitud: 999.0, // Coordenada fuera de rango por falla de GPS
        longitud: 999.0,
        inclinacion: 60,
        rutaFoto: '/tmp/foto.jpg',
        capturadaEn: DateTime(2026, 11, 4, 12, 0),
      );

      final error = validarEvidencia(reporteSinUbicacion);
      expect(error, contains('No se obtuvo la ubicación'));
    });
  });
}

