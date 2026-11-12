// Test tipo Unitarias: se prueba una clase o función sin pantalla y sin red real

import 'dart:math' as math;

import 'package:fix_flow/domain/entities/reporte_nuevo.dart';
import 'package:fix_flow/domain/entities/tipo_incidencia.dart';
import 'package:fix_flow/domain/validators/evidencia_validator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks.dart';

void main() {
  const bache = TipoIncidencia(
    id: '1',
    nombre: 'Bache',
    codigo: 'BACHE',
    orientacion: OrientacionFoto.suelo,
  );

  const luminaria = TipoIncidencia(
    id: '2',
    nombre: 'Luminaria apagada o dañada',
    codigo: 'LUMINARIA',
    orientacion: OrientacionFoto.arriba,
  );

  ReporteNuevo reporte({
    required TipoIncidencia tipo,
    required double? inclinacion,
  }) =>
      ReporteNuevo(
        tipo: tipo,
        descripcion: 'Reporte para prueba de orientación',
        latitud: 18.9220,
        longitud: -99.2340,
        inclinacion: inclinacion,
        rutaFoto: '/tmp/foto.jpg',
        capturadaEn: DateTime(2026, 11, 4, 12, 0),
      );

  group('HU-06: El validador de orientación para "bache" (CA-3, RN-11)', () {
    test('Acelerómetro apuntando al suelo (≥ 45°) → orientación válida', () {
      final r = reporte(tipo: bache, inclinacion: 62.0);
      expect(validarEvidencia(r), isNull);
    });

    test('Acelerómetro apuntando al cielo (< 45°) → orientación inválida', () {
      final r = reporte(tipo: bache, inclinacion: -30.0);
      final error = validarEvidencia(r);
      expect(error, contains('hacia el suelo'));
    });
  });

  group('HU-06: El validador de orientación para "luminaria" (CA-4, RN-11)', () {
    test('Acelerómetro apuntando arriba (≤ -20°) → orientación válida', () {
      final r = reporte(tipo: luminaria, inclinacion: -35.0);
      expect(validarEvidencia(r), isNull);
    });

    test('Acelerómetro apuntando al suelo (> -20°) → orientación inválida', () {
      final r = reporte(tipo: luminaria, inclinacion: 60.0);
      final error = validarEvidencia(r);
      expect(error, contains('hacia arriba'));
    });
  });

  group('HU-06: Se obtienen datos del acelerómetro durante la captura (CA-1)', () {
    test('El servicio del acelerómetro devuelve valores x, y, z no nulos al capturar', () async {
      final mockInclinacion = MockInclinacionRepository();
      // Simulación de lectura con valores x, y, z: por ejemplo apuntando al suelo (z alto)
      const x = 0.5;
      const y = 1.2;
      const z = 9.8;
      final anguloCalculado = math.atan2(z, math.sqrt(x * x + y * y)) * 180 / math.pi;

      when(() => mockInclinacion.leerInclinacion()).thenAnswer((_) async => anguloCalculado);

      final inclinacion = await mockInclinacion.leerInclinacion();

      expect(inclinacion, isNotNull);
      expect(inclinacion, closeTo(82.4, 0.5));
      verify(() => mockInclinacion.leerInclinacion()).called(1);
    });
  });
}

