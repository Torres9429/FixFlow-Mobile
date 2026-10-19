// Test tipo Unitarias: se prueba una clase o función sin pantalla y sin red real

import 'package:fix_flow/domain/validators/campos_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HU-01: El validador de contraseña (CA-4)', () {
    test('abc12345 → sin error', () {
      expect(validarPassword('abc12345'), isNull);
    });

    test('abcdefgh (solo letras) → mensaje de error', () {
      expect(validarPassword('abcdefgh'), isNotNull);
    });

    test('12345678 (solo números) → mensaje de error', () {
      expect(validarPassword('12345678'), isNotNull);
    });

    test('abc123 (menos de 8 caracteres) → mensaje de error', () {
      expect(validarPassword('abc123'), isNotNull);
    });
  });

  group('HU-01: Los validadores de campos obligatorios y del correo (CA-2)', () {
    test('Vacío → "Campo obligatorio"', () {
      expect(validarCorreo(''), 'Campo obligatorio');
      expect(validarObligatorio(''), 'Campo obligatorio');
    });

    test('ana@ → "Correo no válido"', () {
      expect(validarCorreo('ana@'), 'Correo no válido');
    });

    test('ana@mail.com → sin error', () {
      expect(validarCorreo('ana@mail.com'), isNull);
    });
  });
}
