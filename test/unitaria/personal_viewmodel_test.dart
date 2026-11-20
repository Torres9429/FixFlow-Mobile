// Test tipo Unitarias: se prueba una clase o función sin pantalla y sin red real

import 'package:fix_flow/core/result.dart';
import 'package:fix_flow/domain/entities/operativo.dart';
import 'package:fix_flow/presentation/admin/personal/alta_operativo_viewmodel.dart';
import 'package:fix_flow/presentation/admin/personal/personal_viewmodel.dart';
import 'package:fix_flow/presentation/core/estado_consulta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks.dart';

void main() {
  late MockAdminRepository mockAdmin;

  setUp(() {
    mockAdmin = MockAdminRepository();
  });

  const opActivo1 = Operativo(
    id: 1,
    nombre: 'Roberto',
    apellidos: 'Mendoza',
    correo: 'roberto@fixflow.mx',
    activo: true,
    cargaActual: 2,
  );
  const opActivo2 = Operativo(
    id: 2,
    nombre: 'Laura',
    apellidos: 'Sánchez',
    correo: 'laura@fixflow.mx',
    activo: true,
    cargaActual: 0,
  );
  const opInactivo = Operativo(
    id: 3,
    nombre: 'Mario',
    apellidos: 'Gómez',
    correo: 'mario@fixflow.mx',
    activo: false,
    cargaActual: 0,
  );

  final listaOperativos = [opActivo1, opActivo2, opInactivo];

  group('HU-24: Gestionar personal operativo', () {
    test('Filtrado local de personal por búsqueda y estatus (CA-1)', () async {
      when(() => mockAdmin.listarOperativos()).thenAnswer((_) async => Result.ok(listaOperativos));

      final vm = PersonalViewModel(adminRepository: mockAdmin);
      await vm.iniciar();

      expect(vm.estado, isA<Listo<List<Operativo>>>());
      expect(vm.visibles, hasLength(3));

      // Filtrar por estatus Activos
      vm.filtrar(FiltroPersonal.activos);
      expect(vm.visibles, hasLength(2));
      expect(vm.visibles.every((o) => o.activo), isTrue);

      // Filtrar por estatus Inactivos
      vm.filtrar(FiltroPersonal.inactivos);
      expect(vm.visibles, hasLength(1));
      expect(vm.visibles.single.nombre, 'Mario');

      // Búsqueda por texto (nombre o correo)
      vm.filtrar(FiltroPersonal.todos);
      vm.buscar('laura');
      expect(vm.visibles, hasLength(1));
      expect(vm.visibles.single.nombre, 'Laura');
    });

    test('Modificación de estatus activo/inactivo (CA-4)', () async {
      when(() => mockAdmin.listarOperativos()).thenAnswer((_) async => Result.ok(listaOperativos));
      when(() => mockAdmin.cambiarEstatusOperativo(1, activo: false)).thenAnswer((_) async => const Result.ok(null));

      final vm = PersonalViewModel(adminRepository: mockAdmin);
      await vm.iniciar();

      final ok = await vm.cambiarEstatus(opActivo1);
      expect(ok, isTrue);
      expect(vm.error, isNull);
      verify(() => mockAdmin.cambiarEstatusOperativo(1, activo: false)).called(1);
    });

    test('Creación de cuenta con contraseña temporal (CA-2, CA-3)', () async {
      when(() => mockAdmin.crearOperativo(
            nombre: 'Roberto',
            apellidos: 'Mendoza López',
            correo: 'r.mendoza@fixflow.mx',
            passwordTemporal: 'Temp1234!',
          )).thenAnswer((_) async => const Result.ok(null));

      final vm = AltaOperativoViewModel(adminRepository: mockAdmin);

      final ok = await vm.crear(
        nombre: 'Roberto',
        apellidos: 'Mendoza López',
        correo: 'r.mendoza@fixflow.mx',
        passwordTemporal: 'Temp1234!',
      );

      expect(ok, isTrue);
      expect(vm.guardando, isFalse);
      expect(vm.error, isNull);
      verify(() => mockAdmin.crearOperativo(
            nombre: 'Roberto',
            apellidos: 'Mendoza López',
            correo: 'r.mendoza@fixflow.mx',
            passwordTemporal: 'Temp1234!',
          )).called(1);
    });
  });
}
