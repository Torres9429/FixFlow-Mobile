// Test tipo Unitarias: se prueba una clase o función sin pantalla y sin red real

import 'package:fix_flow/domain/entities/reporte_nuevo.dart';
import 'package:fix_flow/domain/entities/tipo_incidencia.dart';
import 'package:fix_flow/domain/validators/evidencia_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const bache = TipoIncidencia(
    id: '1',
    nombre: 'Bache',
    codigo: 'BACHE',
    orientacion: OrientacionFoto.suelo,
  );

  ReporteNuevo crearReporte({
    String rutaFoto = '/tmp/foto.jpg',
    double latitud = 18.9220,
    double longitud = -99.2340,
    double? inclinacion = 60.0,
  }) =>
      ReporteNuevo(
        tipo: bache,
        descripcion: 'Bache profundo en avenida principal',
        latitud: latitud,
        longitud: longitud,
        inclinacion: inclinacion,
        rutaFoto: rutaFoto,
        capturadaEn: DateTime(2026, 11, 4, 12, 0),
      );

  group('HU-08: Validar evidencia del reporte (RN-12)', () {
    test('Reporte completo pasa la validación (CA-1, CA-2, CA-3, CA-4, RN-12)', () {
      final reporte = crearReporte(
        rutaFoto: '/tmp/evidencia_valida.jpg',
        latitud: 18.9220,
        longitud: -99.2340,
        inclinacion: 60.0, // Cumple ≥ 45° para bache (suelo)
      );

      final resultado = validarEvidencia(reporte);

      // Con foto, ubicación y acelerómetro válidos → la validación retorna éxito (null)
      expect(resultado, isNull);
    });

    test('Reporte sin foto falla la validación (CA-1, RN-09)', () {
      final reporte = crearReporte(rutaFoto: '');

      final resultado = validarEvidencia(reporte);

      expect(resultado, isNotNull);
      expect(resultado, 'Falta la foto. Vuelve a capturarla.');
    });

    test('Reporte sin ubicación falla la validación (CA-3, RN-10)', () {
      // Coordenadas con valores fuera de rango indican ausencia o falla de GPS
      final reporte = crearReporte(latitud: 999.0, longitud: 999.0);

      final resultado = validarEvidencia(reporte);

      expect(resultado, isNotNull);
      expect(resultado, 'No se obtuvo la ubicación. Vuelve a capturar la foto.');
    });

    test('Reporte sin datos del acelerómetro falla la validación (CA-4, RN-11)', () {
      final reporte = crearReporte(inclinacion: null);

      final resultado = validarEvidencia(reporte);

      expect(resultado, isNotNull);
      expect(resultado, 'No se pudo medir la inclinación del teléfono. Vuelve a capturar la foto.');
    });
  });
}

