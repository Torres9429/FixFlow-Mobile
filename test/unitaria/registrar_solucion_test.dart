import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fix_flow/core/result.dart';
import 'package:fix_flow/data/repositories/fakes/fake_evidencia_repository.dart';
import 'package:fix_flow/data/repositories/fakes/fake_operativo_repository.dart';
import 'package:fix_flow/data/repositories/operativo_repository_impl.dart';
import 'package:fix_flow/domain/entities/coordenada.dart';
import 'package:fix_flow/domain/entities/estado_incidencia.dart';
import 'package:fix_flow/domain/entities/evento_historial.dart';
import 'package:fix_flow/domain/entities/incidencia_detalle.dart';
import 'package:fix_flow/domain/entities/incidencia_resumen.dart';
import 'package:fix_flow/domain/entities/pagina.dart';
import 'package:fix_flow/domain/entities/prioridad.dart';
import 'package:fix_flow/domain/errors/falla_red.dart';
import 'package:fix_flow/domain/repositories/direccion_repository.dart';
import 'package:fix_flow/domain/repositories/evidencia_repository.dart';
import 'package:fix_flow/domain/validators/campos_validators.dart';
import 'package:fix_flow/presentation/incidencia/detalle_incidencia_viewmodel.dart';
import 'package:fix_flow/presentation/incidencia/vista_detalle.dart';
import 'package:fix_flow/presentation/operativo/solucion/solucion_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks.dart';

class _MockDio extends Mock implements Dio {}

class _MockDireccionRepository extends Mock implements DireccionRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(TipoEvidencia.reporte);
  });

  group('HU-16 / Issue #70: validarDescripcionSolucion', () {
    test('rechaza vacío, espacios o más de 500 caracteres y acepta válido', () {
      expect(validarDescripcionSolucion(null), 'Campo obligatorio');
      expect(validarDescripcionSolucion('   '), 'Campo obligatorio');
      expect(validarDescripcionSolucion('a' * 501), 'Máximo 500 caracteres');
      expect(validarDescripcionSolucion('a' * 500), isNull);
      expect(validarDescripcionSolucion('  Se selló el tramo de tubería.  '), isNull);
    });
  });

  group('HU-16 / Issue #70: OperativoRepositoryImpl y Fakes', () {
    test('envía POST /incidencias/{id}/solucion con y sin coordenadas', () async {
      final dio = _MockDio();
      final repo = OperativoRepositoryImpl(dio);

      when(
        () => dio.post<Map<String, dynamic>>(
          '/incidencias/123/solucion',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          data: {'text': 'Solución registrada correctamente', 'type': 'SUCCESS'},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/incidencias/123/solucion'),
        ),
      );

      final conCoords = await repo.registrarSolucion(
        incidenciaId: 123,
        descripcion: 'Se bacheó el tramo dañado.',
        fotoUrl: 'https://res.cloudinary.com/demo/sol.jpg',
        latitud: 18.92,
        longitud: -99.23,
      );
      expect(conCoords, isA<Ok<void>>());
      verify(
        () => dio.post<Map<String, dynamic>>(
          '/incidencias/123/solucion',
          data: {
            'descripcion': 'Se bacheó el tramo dañado.',
            'fotoUrl': 'https://res.cloudinary.com/demo/sol.jpg',
            'latitud': 18.92,
            'longitud': -99.23,
          },
        ),
      ).called(1);

      final sinCoords = await repo.registrarSolucion(
        incidenciaId: 123,
        descripcion: 'Sin GPS.',
        fotoUrl: 'https://res.cloudinary.com/demo/sol2.jpg',
      );
      expect(sinCoords, isA<Ok<void>>());
      verify(
        () => dio.post<Map<String, dynamic>>(
          '/incidencias/123/solucion',
          data: {
            'descripcion': 'Sin GPS.',
            'fotoUrl': 'https://res.cloudinary.com/demo/sol2.jpg',
          },
        ),
      ).called(1);
    });

    test('traduce HTTP 409 a Conflicto y HTTP 422 a EvidenciaInvalida', () async {
      final dio = _MockDio();
      final repo = OperativoRepositoryImpl(dio);

      when(
        () => dio.post<Map<String, dynamic>>(
          '/incidencias/123/solucion',
          data: any(named: 'data'),
        ),
      ).thenThrow(
        DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/incidencias/123/solucion'),
          response: Response(
            statusCode: 409,
            data: {'text': 'Solo se registra la solución de una incidencia En proceso'},
            requestOptions: RequestOptions(path: '/incidencias/123/solucion'),
          ),
        ),
      );

      final res409 = await repo.registrarSolucion(
        incidenciaId: 123,
        descripcion: 'Texto',
        fotoUrl: 'https://ejemplo.com/a.jpg',
      );
      expect((res409 as Error).error, isA<Conflicto>());

      when(
        () => dio.post<Map<String, dynamic>>(
          '/incidencias/123/solucion',
          data: any(named: 'data'),
        ),
      ).thenThrow(
        DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/incidencias/123/solucion'),
          response: Response(
            statusCode: 422,
            data: {'text': 'La foto de la solución no es válida'},
            requestOptions: RequestOptions(path: '/incidencias/123/solucion'),
          ),
        ),
      );

      final res422 = await repo.registrarSolucion(
        incidenciaId: 123,
        descripcion: 'Texto',
        fotoUrl: 'https://ejemplo.com/a.jpg',
      );
      expect((res422 as Error).error, isA<EvidenciaInvalida>());
    });

    test('FakeOperativoRepository transita a RESUELTA, sale de activas y no comparte estado', () async {
      final fake1 = FakeOperativoRepository();
      final fake2 = FakeOperativoRepository();

      final res = await fake1.registrarSolucion(
        incidenciaId: 123,
        descripcion: 'Trabajo terminado.',
        fotoUrl: 'https://res.cloudinary.com/demo/sol.jpg',
      );
      expect(res, isA<Ok<void>>());

      final activas = (await fake1.asignadas() as Ok<Pagina<IncidenciaResumen>>).value.contenido;
      expect(activas.any((i) => i.id == 123), isFalse);

      final resueltas = (await fake1.asignadas(estado: EstadoIncidencia.resuelta) as Ok<Pagina<IncidenciaResumen>>)
          .value
          .contenido;
      expect(resueltas.any((i) => i.id == 123), isTrue);

      final activasFake2 = (await fake2.asignadas() as Ok<Pagina<IncidenciaResumen>>).value.contenido;
      expect(activasFake2.firstWhere((i) => i.id == 123).estado, EstadoIncidencia.enProceso);
    });

    test('FakeEvidenciaRepository regresa URL en carpeta soluciones cuando tipo = solucion', () async {
      final fake = FakeEvidenciaRepository();
      final res = await fake.subirFoto('/tmp/sol.jpg', tipo: TipoEvidencia.solucion);
      expect(res, isA<Ok<String>>());
      expect((res as Ok<String>).value, contains('/soluciones/'));
    });
  });

  group('HU-16 / Issue #70: DetalleIncidenciaViewModel y SolucionViewModel', () {
    late MockOperativoRepository mockOperativoRepo;
    late MockEvidenciaRepository mockEvidenciaRepo;
    late MockUbicacionRepository mockUbicacionRepo;
    late MockAuthRepository mockAuthRepo;
    late MockIncidenciasRepository mockIncidenciasRepo;
    late _MockDireccionRepository mockDireccionRepo;

    setUp(() {
      mockOperativoRepo = MockOperativoRepository();
      mockEvidenciaRepo = MockEvidenciaRepository();
      mockUbicacionRepo = MockUbicacionRepository();
      mockAuthRepo = MockAuthRepository();
      mockIncidenciasRepo = MockIncidenciasRepository();
      mockDireccionRepo = _MockDireccionRepository();
    });

    IncidenciaDetalle crearDetalle(EstadoIncidencia estado) => IncidenciaDetalle(
      resumen: IncidenciaResumen(
        id: 123,
        folio: 'FX-2026-000123',
        tipo: 'Bache',
        tipoCodigo: 'BACHE',
        estado: estado,
        prioridad: Prioridad.media,
        motivoPrioridad: 'Tipo de incidencia: Bache',
        latitud: 18.92,
        longitud: -99.23,
        fechaCreacion: DateTime(2026, 3, 1),
        ultimaActualizacion: DateTime(2026, 3, 2),
        operativo: 'Luis Ramírez',
      ),
      descripcion: 'Bache en avenida',
      numReaperturas: 0,
      operativoAsignado: 'Luis Ramírez',
    );

    test('DetalleIncidenciaViewModel.puedeRegistrarSolucion solo es true en EN_PROCESO para operativo', () async {
      when(() => mockIncidenciasRepo.historial(123)).thenAnswer((_) async => const Result.ok(<EventoHistorial>[]));
      when(() => mockDireccionRepo.direccion(any(), any())).thenAnswer((_) async => null);

      for (final estado in EstadoIncidencia.values) {
        when(() => mockIncidenciasRepo.detalle(123)).thenAnswer((_) async => Result.ok(crearDetalle(estado)));
        final vmOp = DetalleIncidenciaViewModel(
          id: 123,
          vista: VistaDetalle.operativo,
          incidenciasRepository: mockIncidenciasRepo,
          direccionRepository: mockDireccionRepo,
          operativoRepository: mockOperativoRepo,
        );
        await vmOp.iniciar();
        expect(vmOp.puedeRegistrarSolucion, estado == EstadoIncidencia.enProceso);
      }

      when(() => mockIncidenciasRepo.detalle(123)).thenAnswer(
        (_) async => Result.ok(crearDetalle(EstadoIncidencia.enProceso)),
      );
      for (final vista in [VistaDetalle.admin, VistaDetalle.ciudadano]) {
        final vmOtro = DetalleIncidenciaViewModel(
          id: 123,
          vista: vista,
          incidenciasRepository: mockIncidenciasRepo,
          direccionRepository: mockDireccionRepo,
          operativoRepository: mockOperativoRepo,
        );
        await vmOtro.iniciar();
        expect(vmOtro.puedeRegistrarSolucion, isFalse);
      }
    });

    test('SolucionViewModel carga nombre y valida campos sin llamar repositorios si faltan', () async {
      when(() => mockAuthRepo.nombreUsuario()).thenAnswer((_) async => 'Luis Ramírez');
      final vm = SolucionViewModel(
        id: 123,
        operativoRepository: mockOperativoRepo,
        evidenciaRepository: mockEvidenciaRepo,
        ubicacionRepository: mockUbicacionRepo,
        authRepository: mockAuthRepo,
      );

      await vm.iniciar();
      expect(vm.nombreOperativo, 'Luis Ramírez');

      final ok = await vm.enviar();
      expect(ok, isFalse);
      expect(vm.errorFoto, 'Toma una foto del trabajo terminado');
      expect(vm.errorDescripcion, 'Campo obligatorio');
      verifyNever(() => mockEvidenciaRepo.subirFoto(any(), tipo: any(named: 'tipo')));
      verifyNever(
        () => mockOperativoRepo.registrarSolucion(
          incidenciaId: any(named: 'incidenciaId'),
          descripcion: any(named: 'descripcion'),
          fotoUrl: any(named: 'fotoUrl'),
          latitud: any(named: 'latitud'),
          longitud: any(named: 'longitud'),
        ),
      );
    });

    test('SolucionViewModel flujo feliz: sube foto SOLUCION, lee GPS y registra solución', () async {
      when(() => mockEvidenciaRepo.subirFoto('/tmp/sol.jpg', tipo: TipoEvidencia.solucion))
          .thenAnswer((_) async => const Result.ok('https://cdn.example/sol.jpg'));
      when(() => mockUbicacionRepo.posicionActual()).thenAnswer((_) async => const Coordenada(18.92, -99.23));
      when(
        () => mockOperativoRepo.registrarSolucion(
          incidenciaId: 123,
          descripcion: 'Bache reparado',
          fotoUrl: 'https://cdn.example/sol.jpg',
          latitud: 18.92,
          longitud: -99.23,
        ),
      ).thenAnswer((_) async => const Result.ok(null));

      final vm = SolucionViewModel(
        id: 123,
        operativoRepository: mockOperativoRepo,
        evidenciaRepository: mockEvidenciaRepo,
        ubicacionRepository: mockUbicacionRepo,
        authRepository: mockAuthRepo,
      );

      vm.establecerFoto('/tmp/sol.jpg');
      vm.cambiarDescripcion('  Bache reparado  ');
      final ok = await vm.enviar();

      expect(ok, isTrue);
      expect(vm.enviada, isTrue);
      expect(vm.enviando, isFalse);
      expect(vm.errorGeneral, isNull);
    });

    test('SolucionViewModel no re-sube foto al reintentar (RNF-08) salvo EvidenciaInvalida o cambio de foto',
        () async {
      when(() => mockEvidenciaRepo.subirFoto('/tmp/sol1.jpg', tipo: TipoEvidencia.solucion))
          .thenAnswer((_) async => const Result.ok('https://cdn.example/sol1.jpg'));
      when(() => mockEvidenciaRepo.subirFoto('/tmp/sol2.jpg', tipo: TipoEvidencia.solucion))
          .thenAnswer((_) async => const Result.ok('https://cdn.example/sol2.jpg'));
      when(() => mockUbicacionRepo.posicionActual()).thenAnswer((_) async => null);

      var intentos = 0;
      when(
        () => mockOperativoRepo.registrarSolucion(
          incidenciaId: any(named: 'incidenciaId'),
          descripcion: any(named: 'descripcion'),
          fotoUrl: any(named: 'fotoUrl'),
          latitud: any(named: 'latitud'),
          longitud: any(named: 'longitud'),
        ),
      ).thenAnswer((_) async {
        intentos++;
        if (intentos == 1) return const Result.error(SinConexion());
        if (intentos == 2) return const Result.ok(null);
        return const Result.error(EvidenciaInvalida('Foto no válida'));
      });

      final vm = SolucionViewModel(
        id: 123,
        operativoRepository: mockOperativoRepo,
        evidenciaRepository: mockEvidenciaRepo,
        ubicacionRepository: mockUbicacionRepo,
        authRepository: mockAuthRepo,
      );

      vm.establecerFoto('/tmp/sol1.jpg');
      vm.cambiarDescripcion('Trabajo listo');

      expect(await vm.enviar(), isFalse);
      expect(vm.errorGeneral, contains('No pudimos comunicarnos'));

      expect(await vm.enviar(), isTrue);
      verify(() => mockEvidenciaRepo.subirFoto('/tmp/sol1.jpg', tipo: TipoEvidencia.solucion)).called(1);

      vm.establecerFoto('/tmp/sol2.jpg');
      expect(await vm.enviar(), isFalse);
      expect(vm.errorGeneral, 'Foto no válida');
      verify(() => mockEvidenciaRepo.subirFoto('/tmp/sol2.jpg', tipo: TipoEvidencia.solucion)).called(1);
    });

    test('SolucionViewModel propaga error de subirFoto sin URL fallback e ignora doble envío', () async {
      final completer = Completer<Result<String>>();
      when(() => mockEvidenciaRepo.subirFoto('/tmp/sol.jpg', tipo: TipoEvidencia.solucion))
          .thenAnswer((_) => completer.future);

      final vm = SolucionViewModel(
        id: 123,
        operativoRepository: mockOperativoRepo,
        evidenciaRepository: mockEvidenciaRepo,
        ubicacionRepository: mockUbicacionRepo,
        authRepository: mockAuthRepo,
      );

      vm.establecerFoto('/tmp/sol.jpg');
      vm.cambiarDescripcion('Reparado');

      final f1 = vm.enviar();
      expect(vm.enviando, isTrue);
      final f2 = await vm.enviar();
      expect(f2, isFalse);

      completer.complete(const Result.error(ErrorDelServidor(503)));
      expect(await f1, isFalse);
      expect(vm.errorGeneral, 'FixFlow tuvo un problema. Intenta más tarde.');
      verify(() => mockEvidenciaRepo.subirFoto('/tmp/sol.jpg', tipo: TipoEvidencia.solucion)).called(1);
      verifyNever(
        () => mockOperativoRepo.registrarSolucion(
          incidenciaId: any(named: 'incidenciaId'),
          descripcion: any(named: 'descripcion'),
          fotoUrl: any(named: 'fotoUrl'),
          latitud: any(named: 'latitud'),
          longitud: any(named: 'longitud'),
        ),
      );
    });
  });
}
