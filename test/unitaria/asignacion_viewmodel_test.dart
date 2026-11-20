// Test tipo Unitarias: se prueba una clase o función sin pantalla y sin red real

import 'package:fix_flow/core/result.dart';
import 'package:fix_flow/domain/entities/estado_incidencia.dart';
import 'package:fix_flow/domain/entities/incidencia_detalle.dart';
import 'package:fix_flow/domain/entities/incidencia_resumen.dart';
import 'package:fix_flow/domain/entities/operativo.dart';
import 'package:fix_flow/domain/entities/prioridad.dart';
import 'package:fix_flow/domain/repositories/direccion_repository.dart';
import 'package:fix_flow/presentation/admin/asignacion/asignacion_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks.dart';

class MockDireccionRepository extends Mock implements DireccionRepository {}

void main() {
  late MockAdminRepository mockAdmin;
  late MockIncidenciasRepository mockIncidencias;
  late MockDireccionRepository mockDireccion;

  setUp(() {
    mockAdmin = MockAdminRepository();
    mockIncidencias = MockIncidenciasRepository();
    mockDireccion = MockDireccionRepository();
  });

  IncidenciaDetalle crearDetalle({int id = 50, int? operativoId, String? operativoNombre}) => IncidenciaDetalle(
        resumen: IncidenciaResumen(
          id: id,
          folio: 'FX-2026-000050',
          tipo: 'Bache',
          tipoCodigo: 'BACHE',
          estado: operativoId != null ? EstadoIncidencia.asignada : EstadoIncidencia.pendiente,
          prioridad: Prioridad.alta,
          motivoPrioridad: 'Prioridad alta',
          latitud: 18.92,
          longitud: -99.23,
          fechaCreacion: DateTime(2026, 11, 1),
          ultimaActualizacion: DateTime(2026, 11, 2),
        ),
        descripcion: 'Bache grande',
        numReaperturas: 0,
        ciudadano: 'Ana',
        operativoAsignado: operativoNombre,
        operativoAsignadoId: operativoId,
      );

  final operativos = [
    const Operativo(
      id: 10,
      nombre: 'Luis',
      apellidos: 'Ramírez',
      correo: 'luis@fixflow.mx',
      activo: true,
      cargaActual: 3,
    ),
    const Operativo(
      id: 11,
      nombre: 'Carlos',
      apellidos: 'Mendoza',
      correo: 'carlos@fixflow.mx',
      activo: true,
      cargaActual: 1,
    ),
  ];

  group('HU-21: Asignar incidencia a personal operativo', () {
    test('Selección obligatoria de operativo al confirmar (CA-2)', () async {
      when(() => mockIncidencias.detalle(50)).thenAnswer((_) async => Result.ok(crearDetalle()));
      when(() => mockAdmin.operativosDisponibles()).thenAnswer((_) async => Result.ok(operativos));
      when(() => mockDireccion.direccion(any(), any())).thenAnswer((_) async => null);

      final vm = AsignacionViewModel(
        id: 50,
        adminRepository: mockAdmin,
        direccionRepository: mockDireccion,
        incidenciasRepository: mockIncidencias,
      );

      await vm.iniciar();
      expect(vm.operativoSeleccionado, isNull);

      final ok = await vm.confirmar();
      expect(ok, isFalse);
      expect(vm.errorFormulario, 'Selecciona un operativo para continuar.');
      verifyNever(() => mockAdmin.asignarIncidencia(any(), any()));
    });

    test('Preselección de responsable en reasignación E6 (CA-8)', () async {
      when(() => mockIncidencias.detalle(50)).thenAnswer(
        (_) async => Result.ok(crearDetalle(operativoId: 10, operativoNombre: 'Luis Ramírez')),
      );
      when(() => mockAdmin.operativosDisponibles()).thenAnswer((_) async => Result.ok(operativos));
      when(() => mockDireccion.direccion(any(), any())).thenAnswer((_) async => null);

      final vm = AsignacionViewModel(
        id: 50,
        adminRepository: mockAdmin,
        direccionRepository: mockDireccion,
        incidenciasRepository: mockIncidencias,
      );

      await vm.iniciar();

      expect(vm.esReasignacion, isTrue);
      expect(vm.operativoSeleccionado, 10);
    });

    test('Envío de asignación exitosa a través de AdminRepository (CA-3)', () async {
      when(() => mockIncidencias.detalle(50)).thenAnswer((_) async => Result.ok(crearDetalle()));
      when(() => mockAdmin.operativosDisponibles()).thenAnswer((_) async => Result.ok(operativos));
      when(() => mockDireccion.direccion(any(), any())).thenAnswer((_) async => null);
      when(() => mockAdmin.asignarIncidencia(50, 11)).thenAnswer((_) async => const Result.ok(null));

      final vm = AsignacionViewModel(
        id: 50,
        adminRepository: mockAdmin,
        direccionRepository: mockDireccion,
        incidenciasRepository: mockIncidencias,
      );

      await vm.iniciar();
      vm.seleccionar(11);
      expect(vm.operativoSeleccionado, 11);

      final ok = await vm.confirmar();
      expect(ok, isTrue);
      expect(vm.errorFormulario, isNull);
      verify(() => mockAdmin.asignarIncidencia(50, 11)).called(1);
    });
  });
}
