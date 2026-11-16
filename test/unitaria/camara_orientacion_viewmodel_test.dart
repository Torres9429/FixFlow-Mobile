import 'package:fix_flow/data/repositories/fakes/fake_inclinacion_repository.dart';
import 'package:fix_flow/domain/entities/tipo_incidencia.dart';
import 'package:fix_flow/presentation/reporte/camara/camara_orientacion_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const bache = TipoIncidencia(
    id: '1',
    nombre: 'Bache',
    codigo: 'BACHE',
    orientacion: OrientacionFoto.suelo,
  );

  const luminaria = TipoIncidencia(
    id: '2',
    nombre: 'Luminaria',
    codigo: 'LUMINARIA',
    orientacion: OrientacionFoto.arriba,
  );

  const fuga = TipoIncidencia(
    id: '3',
    nombre: 'Fuga de agua',
    codigo: 'FUGA',
    orientacion: OrientacionFoto.sinRestriccion,
  );

  group('HU-06 / Issue #23: Validación de orientación y guía en cámara', () {
    test('Bache a 18° → Fuera de rango, faltan 27° y disparador deshabilitado', () async {
      final repo = FakeInclinacionRepository(inclinacionInicial: 18.0);
      final vm = CamaraOrientacionViewModel(tipo: bache, inclinacionRepository: repo);

      // Esperar la emisión inicial del stream
      await Future<void>.delayed(Duration.zero);

      expect(vm.enRango, isFalse);
      expect(vm.gradosFaltantes, 27);
      expect(vm.estadoTexto, 'Inclina hacia el suelo');
      expect(vm.textoAyuda, contains('Faltan 27°'));
      expect(vm.disparadorActivo, isFalse);

      vm.dispose();
    });

    test('Bache a 62° → Dentro de rango verde (≥ 45°) y disparador habilitado', () async {
      final repo = FakeInclinacionRepository(inclinacionInicial: 62.0);
      final vm = CamaraOrientacionViewModel(tipo: bache, inclinacionRepository: repo);

      await Future<void>.delayed(Duration.zero);

      expect(vm.enRango, isTrue);
      expect(vm.gradosFaltantes, 0);
      expect(vm.estadoTexto, '✓ Ángulo correcto');
      expect(vm.disparadorActivo, isTrue);

      vm.dispose();
    });

    test('Luminaria a -35° → Dentro de rango verde (≤ -20°) y disparador habilitado', () async {
      final repo = FakeInclinacionRepository(inclinacionInicial: -35.0);
      final vm = CamaraOrientacionViewModel(tipo: luminaria, inclinacionRepository: repo);

      await Future<void>.delayed(Duration.zero);

      expect(vm.enRango, isTrue);
      expect(vm.gradosFaltantes, 0);
      expect(vm.estadoTexto, '✓ Ángulo correcto');
      expect(vm.textoPie, contains('basta con apuntar hacia arriba'));
      expect(vm.disparadorActivo, isTrue);

      vm.dispose();
    });

    test('Luminaria a 10° → Fuera de rango, faltan 30° para entrar en ≤ -20°', () async {
      final repo = FakeInclinacionRepository(inclinacionInicial: 10.0);
      final vm = CamaraOrientacionViewModel(tipo: luminaria, inclinacionRepository: repo);

      await Future<void>.delayed(Duration.zero);

      expect(vm.enRango, isFalse);
      expect(vm.gradosFaltantes, 30);
      expect(vm.estadoTexto, 'Inclina hacia arriba');
      expect(vm.disparadorActivo, isFalse);

      vm.dispose();
    });

    test('Fuga de agua a 5° → Sin restricción de ángulo, sensores listos y disparador activo', () async {
      final repo = FakeInclinacionRepository(inclinacionInicial: 5.0);
      final vm = CamaraOrientacionViewModel(tipo: fuga, inclinacionRepository: repo);

      await Future<void>.delayed(Duration.zero);

      expect(vm.enRango, isTrue);
      expect(vm.gradosFaltantes, 0);
      expect(vm.estadoTexto, '✓ Sensores listos');
      expect(vm.disparadorActivo, isTrue);

      vm.dispose();
    });

    test('El movimiento del acelerómetro actualiza el ViewModel en tiempo real', () async {
      final repo = FakeInclinacionRepository(inclinacionInicial: 10.0);
      final vm = CamaraOrientacionViewModel(tipo: bache, inclinacionRepository: repo);

      await Future<void>.delayed(Duration.zero);
      expect(vm.disparadorActivo, isFalse);

      // Simular que el usuario inclina el teléfono hacia el suelo (50°)
      repo.simularInclinacion(50.0);
      await Future<void>.delayed(Duration.zero);

      expect(vm.enRango, isTrue);
      expect(vm.anguloActual, 50.0);
      expect(vm.disparadorActivo, isTrue);

      vm.dispose();
    });

    test('El disparador se desactiva mientras está capturando la fotografía', () async {
      final repo = FakeInclinacionRepository(inclinacionInicial: 60.0);
      final vm = CamaraOrientacionViewModel(tipo: bache, inclinacionRepository: repo);

      await Future<void>.delayed(Duration.zero);
      expect(vm.disparadorActivo, isTrue);

      vm.setCapturando(true);
      expect(vm.disparadorActivo, isFalse);

      vm.setCapturando(false);
      expect(vm.disparadorActivo, isTrue);

      vm.dispose();
    });
  });
}

