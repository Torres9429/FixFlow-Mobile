import 'package:dio/dio.dart';
import 'package:fix_flow/core/result.dart';
import 'package:fix_flow/data/repositories/fakes/fake_operativo_repository.dart';
import 'package:fix_flow/data/repositories/operativo_repository_impl.dart';
import 'package:fix_flow/domain/entities/estado_incidencia.dart';
import 'package:fix_flow/domain/entities/evento_historial.dart';
import 'package:fix_flow/domain/entities/incidencia_detalle.dart';
import 'package:fix_flow/domain/entities/incidencia_resumen.dart';
import 'package:fix_flow/domain/entities/pagina.dart';
import 'package:fix_flow/domain/entities/prioridad.dart';
import 'package:fix_flow/domain/repositories/direccion_repository.dart';
import 'package:fix_flow/presentation/incidencia/detalle_incidencia_viewmodel.dart';
import 'package:fix_flow/presentation/incidencia/vista_detalle.dart';
import 'package:fix_flow/presentation/operativo/asignadas/asignadas_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks.dart';

class MockDio extends Mock implements Dio {}
class MockDireccionRepository extends Mock implements DireccionRepository {}

void main() {
  group('HU-15 / Issue #46: Iniciar atención', () {
    late MockOperativoRepository mockOperativoRepo;
    late MockIncidenciasRepository mockIncidenciasRepo;
    late MockDireccionRepository mockDireccionRepo;
    late MockAuthRepository mockAuthRepo;
    late MockUbicacionRepository mockUbicacionRepo;

    setUp(() {
      mockOperativoRepo = MockOperativoRepository();
      mockIncidenciasRepo = MockIncidenciasRepository();
      mockDireccionRepo = MockDireccionRepository();
      mockAuthRepo = MockAuthRepository();
      mockUbicacionRepo = MockUbicacionRepository();
    });

    IncidenciaResumen crearResumen({required EstadoIncidencia estado, int id = 131}) => IncidenciaResumen(
      id: id,
      folio: 'FX-2026-000$id',
      tipo: 'Bache',
      tipoCodigo: 'BACHE',
      estado: estado,
      prioridad: Prioridad.alta,
      motivoPrioridad: 'Prioridad alta',
      latitud: 18.92,
      longitud: -99.23,
      fechaCreacion: DateTime(2026, 3, 1),
      ultimaActualizacion: DateTime(2026, 3, 2),
      operativo: 'Luis Ramírez',
    );

    IncidenciaDetalle crearDetalle({required EstadoIncidencia estado, int id = 131}) => IncidenciaDetalle(
      resumen: crearResumen(estado: estado, id: id),
      descripcion: 'Bache profundo en avenida principal.',
      numReaperturas: estado == EstadoIncidencia.reabierta ? 1 : 0,
      ciudadano: 'Ana López',
      operativoAsignado: 'Luis Ramírez',
    );

    test('OperativoRepositoryImpl envía PATCH /incidencias/{id}/estado con EN_PROCESO', () async {
      final dio = MockDio();
      final repo = OperativoRepositoryImpl(dio);

      when(
        () => dio.patch<Map<String, dynamic>>(
          '/incidencias/131/estado',
          data: {'estado': 'EN_PROCESO'},
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          data: {'result': null, 'text': 'Estado actualizado correctamente', 'type': 'SUCCESS'},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/incidencias/131/estado'),
        ),
      );

      final resultado = await repo.iniciarAtencion(131);

      expect(resultado, isA<Ok<void>>());
      verify(
        () => dio.patch<Map<String, dynamic>>(
          '/incidencias/131/estado',
          data: {'estado': 'EN_PROCESO'},
        ),
      ).called(1);
    });

    test('FakeOperativoRepository transita la incidencia a EN_PROCESO', () async {
      final fake = FakeOperativoRepository();

      final resAntes = await fake.asignadas();
      expect(resAntes, isA<Ok<Pagina<IncidenciaResumen>>>());
      final listaAntes = (resAntes as Ok<Pagina<IncidenciaResumen>>).value.contenido;
      final incidencia131 = listaAntes.firstWhere((i) => i.id == 131);
      expect(incidencia131.estado, EstadoIncidencia.asignada);

      final resIniciar = await fake.iniciarAtencion(131);
      expect(resIniciar, isA<Ok<void>>());

      final resDespues = await fake.asignadas();
      final listaDespues = (resDespues as Ok<Pagina<IncidenciaResumen>>).value.contenido;
      final incidenciaActualizada = listaDespues.firstWhere((i) => i.id == 131);
      expect(incidenciaActualizada.estado, EstadoIncidencia.enProceso);
    });

    test('DetalleIncidenciaViewModel: puedeIniciarAtencion es true para operativo en ASIGNADA y REABIERTA', () async {
      final vmAsignada = DetalleIncidenciaViewModel(
        id: 131,
        vista: VistaDetalle.operativo,
        incidenciasRepository: mockIncidenciasRepo,
        direccionRepository: mockDireccionRepo,
        operativoRepository: mockOperativoRepo,
      );

      when(() => mockIncidenciasRepo.detalle(131)).thenAnswer(
        (_) async => Result.ok(crearDetalle(estado: EstadoIncidencia.asignada)),
      );
      when(() => mockIncidenciasRepo.historial(131)).thenAnswer(
        (_) async => const Result.ok(<EventoHistorial>[]),
      );
      when(() => mockDireccionRepo.direccion(any(), any())).thenAnswer((_) async => null);

      await vmAsignada.iniciar();
      expect(vmAsignada.puedeIniciarAtencion, isTrue);

      // Ahora con REABIERTA
      final vmReabierta = DetalleIncidenciaViewModel(
        id: 97,
        vista: VistaDetalle.operativo,
        incidenciasRepository: mockIncidenciasRepo,
        direccionRepository: mockDireccionRepo,
        operativoRepository: mockOperativoRepo,
      );

      when(() => mockIncidenciasRepo.detalle(97)).thenAnswer(
        (_) async => Result.ok(crearDetalle(estado: EstadoIncidencia.reabierta, id: 97)),
      );
      when(() => mockIncidenciasRepo.historial(97)).thenAnswer(
        (_) async => const Result.ok(<EventoHistorial>[]),
      );

      await vmReabierta.iniciar();
      expect(vmReabierta.puedeIniciarAtencion, isTrue);
    });

    test('DetalleIncidenciaViewModel: puedeIniciarAtencion es false para ciudadano, admin o estados no válidos', () async {
      // Admin viendo una incidencia asignada
      final vmAdmin = DetalleIncidenciaViewModel(
        id: 131,
        vista: VistaDetalle.admin,
        incidenciasRepository: mockIncidenciasRepo,
        direccionRepository: mockDireccionRepo,
        operativoRepository: mockOperativoRepo,
      );
      when(() => mockIncidenciasRepo.detalle(131)).thenAnswer(
        (_) async => Result.ok(crearDetalle(estado: EstadoIncidencia.asignada)),
      );
      when(() => mockIncidenciasRepo.historial(131)).thenAnswer(
        (_) async => const Result.ok(<EventoHistorial>[]),
      );
      when(() => mockDireccionRepo.direccion(any(), any())).thenAnswer((_) async => null);

      await vmAdmin.iniciar();
      expect(vmAdmin.puedeIniciarAtencion, isFalse);

      // Operativo viendo una incidencia que ya está EN_PROCESO
      final vmEnProceso = DetalleIncidenciaViewModel(
        id: 123,
        vista: VistaDetalle.operativo,
        incidenciasRepository: mockIncidenciasRepo,
        direccionRepository: mockDireccionRepo,
        operativoRepository: mockOperativoRepo,
      );
      when(() => mockIncidenciasRepo.detalle(123)).thenAnswer(
        (_) async => Result.ok(crearDetalle(estado: EstadoIncidencia.enProceso, id: 123)),
      );
      when(() => mockIncidenciasRepo.historial(123)).thenAnswer(
        (_) async => const Result.ok(<EventoHistorial>[]),
      );

      await vmEnProceso.iniciar();
      expect(vmEnProceso.puedeIniciarAtencion, isFalse);
    });

    test('DetalleIncidenciaViewModel: iniciarAtencion invoca al repositorio y recarga el detalle', () async {
      final vm = DetalleIncidenciaViewModel(
        id: 131,
        vista: VistaDetalle.operativo,
        incidenciasRepository: mockIncidenciasRepo,
        direccionRepository: mockDireccionRepo,
        operativoRepository: mockOperativoRepo,
      );

      when(() => mockIncidenciasRepo.detalle(131)).thenAnswer(
        (_) async => Result.ok(crearDetalle(estado: EstadoIncidencia.asignada)),
      );
      when(() => mockIncidenciasRepo.historial(131)).thenAnswer(
        (_) async => const Result.ok(<EventoHistorial>[]),
      );
      when(() => mockDireccionRepo.direccion(any(), any())).thenAnswer((_) async => null);
      when(() => mockOperativoRepo.iniciarAtencion(131)).thenAnswer((_) async => const Result.ok(null));

      await vm.iniciar();
      expect(vm.puedeIniciarAtencion, isTrue);

      // Ahora se simula que el back actualizó el estado a enProceso tras iniciarAtencion
      when(() => mockIncidenciasRepo.detalle(131)).thenAnswer(
        (_) async => Result.ok(crearDetalle(estado: EstadoIncidencia.enProceso)),
      );

      final res = await vm.iniciarAtencion();

      expect(res, isA<Ok<void>>());
      verify(() => mockOperativoRepo.iniciarAtencion(131)).called(1);
      expect(vm.puedeIniciarAtencion, isFalse);
    });

    test('AsignadasViewModel: iniciarAtencion invoca al repositorio y recarga la lista', () async {
      final vm = AsignadasViewModel(
        operativoRepository: mockOperativoRepo,
        ubicacionRepository: mockUbicacionRepo,
        authRepository: mockAuthRepo,
      );

      when(() => mockAuthRepo.nombreUsuario()).thenAnswer((_) async => 'Luis');
      when(() => mockUbicacionRepo.posicionActual()).thenAnswer((_) async => null);
      when(() => mockOperativoRepo.asignadas(estado: any(named: 'estado'), pagina: any(named: 'pagina')))
          .thenAnswer(
        (_) async => Result.ok(Pagina(
          contenido: [crearResumen(estado: EstadoIncidencia.asignada, id: 131)],
          numero: 0,
          totalPaginas: 1,
        )),
      );
      when(() => mockOperativoRepo.iniciarAtencion(131)).thenAnswer((_) async => const Result.ok(null));

      await vm.iniciar();
      expect(vm.asignadas.first.estado, EstadoIncidencia.asignada);

      // Simula que al recargar la lista ahora viene enProceso
      when(() => mockOperativoRepo.asignadas(estado: any(named: 'estado'), pagina: any(named: 'pagina')))
          .thenAnswer(
        (_) async => Result.ok(Pagina(
          contenido: [crearResumen(estado: EstadoIncidencia.enProceso, id: 131)],
          numero: 0,
          totalPaginas: 1,
        )),
      );

      final res = await vm.iniciarAtencion(131);

      expect(res, isA<Ok<void>>());
      expect(vm.iniciandoId, isNull);
      verify(() => mockOperativoRepo.iniciarAtencion(131)).called(1);
      expect(vm.asignadas.first.estado, EstadoIncidencia.enProceso);
    });
  });
}
