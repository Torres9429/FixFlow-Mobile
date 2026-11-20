// Test tipo Unitarias: se prueba una clase o función sin pantalla y sin red real

import 'package:fix_flow/core/result.dart';
import 'package:fix_flow/domain/entities/prioridad.dart';
import 'package:fix_flow/domain/entities/tipo_incidencia.dart';
import 'package:fix_flow/domain/errors/falla_red.dart';
import 'package:fix_flow/domain/validators/campos_validators.dart';
import 'package:fix_flow/presentation/admin/catalogo/catalogo_tipos_viewmodel.dart';
import 'package:fix_flow/presentation/admin/catalogo/tipo_form_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks.dart';

class FakeDatosTipo extends Fake implements DatosTipo {}

void main() {
  late MockIncidenceTypeRepository mockTipos;

  setUpAll(() {
    registerFallbackValue(FakeDatosTipo());
  });

  setUp(() {
    mockTipos = MockIncidenceTypeRepository();
  });

  const tipo1 = TipoIncidencia(
    id: '1',
    nombre: 'Fuga de agua',
    codigo: 'FUGA_DE_AGUA',
    orientacion: OrientacionFoto.sinRestriccion,
    prioridadBase: Prioridad.alta,
    activo: true,
  );

  group('HU-26: Gestionar el catálogo de tipos de incidencia', () {
    test('Generación automática de código sugerido a partir del nombre (RN-07)', () {
      expect(codigoSugerido('Fuga de agua'), 'FUGA_DE_AGUA');
      expect(codigoSugerido('  Bache profundo  '), 'BACHE_PROFUNDO');
      expect(codigoSugerido('Luminaria dañada/rota'), 'LUMINARIA_DANADA_ROTA');
      expect(codigoSugerido(''), '');
    });

    test('Validadores de nombre y código de tipo de incidencia', () {
      expect(validarNombreTipo(null), 'El nombre es obligatorio');
      expect(validarNombreTipo('   '), 'El nombre es obligatorio');
      expect(validarNombreTipo('a' * 81), 'Máximo 80 caracteres');
      expect(validarNombreTipo('Bache'), isNull);

      expect(validarCodigoTipo(''), isNull); // vacío permite autogenerado
      expect(validarCodigoTipo('codigo invalido'), contains('mayúsculas'));
      expect(validarCodigoTipo('BACHE_123'), isNull);
    });

    test('Mapeo de conflicto 409 por código duplicado en formulario', () async {
      when(() => mockTipos.crear(any())).thenAnswer(
        (_) async => const Result.error(Conflicto('El código ya existe')),
      );

      final vm = TipoFormViewModel(tiposRepository: mockTipos);
      vm.cambiarNombre('Fuga de agua');
      vm.cambiarCodigo('FUGA_DE_AGUA');
      vm.elegirOrientacion(OrientacionFoto.sinRestriccion);
      vm.elegirPrioridad(Prioridad.alta);

      final ok = await vm.guardar();

      expect(ok, isFalse);
      expect(vm.errorCodigo, contains('El código ya existe'));
    });

    test('Repositorio de catálogo: cambio de estatus activo/inactivo', () async {
      when(() => mockTipos.catalogo()).thenAnswer((_) async => const Result.ok([tipo1]));
      when(() => mockTipos.cambiarEstatus('1', activo: false)).thenAnswer((_) async => const Result.ok(tipo1));

      final vm = CatalogoTiposViewModel(tiposRepository: mockTipos);
      await vm.cargar();

      final ok = await vm.cambiarEstatus(tipo1);
      expect(ok, isTrue);
      expect(vm.error, isNull);
      verify(() => mockTipos.cambiarEstatus('1', activo: false)).called(1);
    });

    test('Formulario guarda alta o edición según corresponda', () async {
      when(() => mockTipos.crear(any())).thenAnswer((_) async => const Result.ok(tipo1));
      when(() => mockTipos.editar('1', any())).thenAnswer((_) async => const Result.ok(tipo1));

      // Alta: tipo es null
      final vmAlta = TipoFormViewModel(tiposRepository: mockTipos);
      vmAlta.cambiarNombre('Fuga de agua');
      vmAlta.cambiarCodigo('FUGA_DE_AGUA');
      vmAlta.elegirOrientacion(OrientacionFoto.sinRestriccion);
      vmAlta.elegirPrioridad(Prioridad.alta);

      final okAlta = await vmAlta.guardar();
      expect(okAlta, isTrue);
      verify(() => mockTipos.crear(any())).called(1);

      // Edición: tipo provisto
      final vmEdicion = TipoFormViewModel(tiposRepository: mockTipos, tipo: tipo1);
      vmEdicion.cambiarNombre('Fuga de agua potable');

      final okEdicion = await vmEdicion.guardar();
      expect(okEdicion, isTrue);
      verify(() => mockTipos.editar('1', any())).called(1);
    });
  });
}
