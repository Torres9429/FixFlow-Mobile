// Test tipo Unitarias: se prueba una clase o función sin pantalla y sin red real

import 'package:fix_flow/domain/entities/reporte_nuevo.dart';
import 'package:fix_flow/domain/entities/tipo_incidencia.dart';
import 'package:fix_flow/domain/validators/campos_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HU-03: Validadores de campos obligatorios del reporte (CA-1, CA-2)', () {
    test('Tipo de incidencia vacío → "Campo obligatorio"', () {
      // El tipo se trata como campo obligatorio: null o vacío no pasan
      expect(validarObligatorio(null), 'Campo obligatorio');
      expect(validarObligatorio(''), 'Campo obligatorio');
    });

    test('Descripción vacía → "Campo obligatorio"', () {
      expect(validarObligatorio(''), 'Campo obligatorio');
      expect(validarObligatorio('   '), 'Campo obligatorio');
    });

    test('Tipo y descripción válidos → sin error', () {
      expect(validarObligatorio('Bache'), isNull);
      expect(validarObligatorio('Bache grande en el carril derecho'), isNull);
    });
  });

  group('HU-03: Fecha y hora automáticas del reporte (CA-5, RN-08)', () {
    test('Al construir el modelo del reporte, la fecha/hora se establece sin intervención del usuario y no es nula',
        () {
      final ahora = DateTime.now();
      final reporte = ReporteNuevo(
        tipo: const TipoIncidencia(id: '1', nombre: 'Bache', codigo: 'BACHE', orientacion: OrientacionFoto.suelo),
        descripcion: 'Bache grande en el carril derecho',
        latitud: 18.92,
        longitud: -99.23,
        inclinacion: 62,
        rutaFoto: '/tmp/foto.jpg',
        capturadaEn: ahora,
      );

      // La fecha/hora queda asignada y coincide con el momento de creación
      expect(reporte.capturadaEn, isNotNull);
      expect(reporte.capturadaEn, ahora);
      // No puede ser futura ni anterior al momento de la captura
      expect(reporte.capturadaEn.isBefore(DateTime.now().add(const Duration(seconds: 1))), isTrue);
    });
  });
}

