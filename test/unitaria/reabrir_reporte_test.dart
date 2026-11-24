// Test tipo Unitaria: se prueba una parte del código sola, con sus dependencias simuladas

import 'package:dio/dio.dart';
import 'package:fix_flow/core/result.dart';
import 'package:fix_flow/data/repositories/reportes_ciudadano_repository_impl.dart';
import 'package:fix_flow/domain/entities/estado_incidencia.dart';
import 'package:fix_flow/domain/entities/evento_historial.dart';
import 'package:fix_flow/domain/entities/incidencia_detalle.dart';
import 'package:fix_flow/domain/entities/incidencia_resumen.dart';
import 'package:fix_flow/domain/entities/prioridad.dart';
import 'package:fix_flow/domain/errors/falla_red.dart';
import 'package:fix_flow/domain/repositories/direccion_repository.dart';
import 'package:fix_flow/domain/validators/campos_validators.dart';
import 'package:fix_flow/presentation/ciudadano/reabrir/reabrir_reporte_viewmodel.dart';
import 'package:fix_flow/presentation/incidencia/detalle_incidencia_viewmodel.dart';
import 'package:fix_flow/presentation/incidencia/vista_detalle.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks.dart';

class MockDio extends Mock implements Dio {}

class MockDireccionRepository extends Mock implements DireccionRepository {}

void main() {
  group('HU-23 / #72: Reabrir reporte', () {
    late MockIncidenciasRepository incidencias;
    late MockDireccionRepository direccion;
    late MockReportesCiudadanoRepository reportes;

    setUp(() {
      incidencias = MockIncidenciasRepository();
      direccion = MockDireccionRepository();
      reportes = MockReportesCiudadanoRepository();
      when(() => incidencias.historial(any())).thenAnswer((_) async => const Result.ok(<EventoHistorial>[]));
      when(() => direccion.direccion(any(), any())).thenAnswer((_) async => null);
    });

    IncidenciaDetalle detalle(EstadoIncidencia estado, {int numReaperturas = 0}) => IncidenciaDetalle(
      resumen: IncidenciaResumen(
        id: 97,
        folio: 'FX-2026-000097',
        tipo: 'Fuga de agua',
        tipoCodigo: 'FUGA_AGUA',
        estado: estado,
        prioridad: Prioridad.alta,
        motivoPrioridad: 'Tipo de incidencia: Fuga de agua',
        latitud: 18.92,
        longitud: -99.23,
        fechaCreacion: DateTime(2026, 11, 1),
        ultimaActualizacion: DateTime(2026, 11, 3),
        operativo: 'Luis Ramírez',
      ),
      descripcion: 'Fuga visible sobre la banqueta.',
      numReaperturas: numReaperturas,
      descripcionSolucion: 'Se cambió el tramo de tubería dañado.',
    );

    DetalleIncidenciaViewModel crearVm(VistaDetalle vista) => DetalleIncidenciaViewModel(
      id: 97,
      vista: vista,
      incidenciasRepository: incidencias,
      direccionRepository: direccion,
      operativoRepository: MockOperativoRepository(),
      reportesRepository: reportes,
    );

    test('ReportesCiudadanoRepositoryImpl envía POST /incidencias/{id}/reapertura y devuelve el texto del back', () async {
      final dio = MockDio();
      when(
        () => dio.post<Map<String, dynamic>>(
          '/incidencias/97/reapertura',
          data: {'justificacion': 'Sigue saliendo agua'},
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          data: {
            'result': null,
            'text': 'Reporte reabierto; el personal operativo verá tu motivo',
            'type': 'SUCCESS',
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/incidencias/97/reapertura'),
        ),
      );

      final res = await ReportesCiudadanoRepositoryImpl(dio).reabrir(97, 'Sigue saliendo agua');

      expect(res, isA<Ok<String>>());
      expect((res as Ok<String>).value, 'Reporte reabierto; el personal operativo verá tu motivo');
      verify(
        () => dio.post<Map<String, dynamic>>(
          '/incidencias/97/reapertura',
          data: {'justificacion': 'Sigue saliendo agua'},
        ),
      ).called(1);
    });

    test('validarJustificacionReapertura pide entre 10 y 500 caracteres (RN-17)', () {
      expect(validarJustificacionReapertura(''), 'Campo obligatorio');
      expect(validarJustificacionReapertura('123456789'), 'Mínimo 10 caracteres');
      expect(validarJustificacionReapertura(List.filled(501, 'a').join()), 'Máximo 500 caracteres');
      expect(validarJustificacionReapertura('1234567890'), isNull);
    });

    test('Solo el ciudadano con su reporte en Resuelta y menos de 2 reaperturas puede reabrir (RN-17)', () async {
      when(() => incidencias.detalle(97)).thenAnswer((_) async => Result.ok(detalle(EstadoIncidencia.resuelta)));
      final ciudadano = crearVm(VistaDetalle.ciudadano);
      final admin = crearVm(VistaDetalle.admin);
      await (ciudadano.iniciar(), admin.iniciar()).wait;
      expect(ciudadano.puedeReabrir, isTrue);
      expect(admin.puedeReabrir, isFalse);

      when(() => incidencias.detalle(97)).thenAnswer(
        (_) async => Result.ok(detalle(EstadoIncidencia.resuelta, numReaperturas: 1)),
      );
      final unaVez = crearVm(VistaDetalle.ciudadano);
      await unaVez.iniciar();
      expect(unaVez.puedeReabrir, isTrue);

      when(() => incidencias.detalle(97)).thenAnswer(
        (_) async => Result.ok(detalle(EstadoIncidencia.resuelta, numReaperturas: 2)),
      );
      final dosVeces = crearVm(VistaDetalle.ciudadano);
      await dosVeces.iniciar();
      expect(dosVeces.puedeReabrir, isFalse);

      when(() => incidencias.detalle(97)).thenAnswer((_) async => Result.ok(detalle(EstadoIncidencia.cerrada)));
      final cerrada = crearVm(VistaDetalle.ciudadano);
      await cerrada.iniciar();
      expect(cerrada.puedeReabrir, isFalse);
    });

    test('Justificación corta deja error y no llama al repositorio', () async {
      final vm = ReabrirReporteViewModel(id: 97, reportesRepository: reportes);
      vm.cambiarJustificacion('corta');

      final res = await vm.reabrir();

      expect(res, isA<Error<String>>());
      expect(vm.errorJustificacion, 'Mínimo 10 caracteres');
      verifyNever(() => reportes.reabrir(any(), any()));
    });

    test('Justificación válida recorta espacios, llama una vez y devuelve Ok', () async {
      when(() => reportes.reabrir(97, 'Sigue saliendo agua'))
          .thenAnswer((_) async => const Result.ok('Reporte reabierto; el personal operativo verá tu motivo'));
      final vm = ReabrirReporteViewModel(id: 97, reportesRepository: reportes);
      vm.cambiarJustificacion('  Sigue saliendo agua  ');

      final res = await vm.reabrir();

      expect(res, isA<Ok<String>>());
      verify(() => reportes.reabrir(97, 'Sigue saliendo agua')).called(1);
    });

    test('Un 409 del back deja su texto en errorGeneral', () async {
      when(() => reportes.reabrir(97, any()))
          .thenAnswer((_) async => const Result.error(Conflicto('Ya se reabrió 2 veces')));
      final vm = ReabrirReporteViewModel(id: 97, reportesRepository: reportes);
      vm.cambiarJustificacion('Sigue saliendo agua');

      final res = await vm.reabrir();

      expect(res, isA<Error<String>>());
      expect(vm.errorGeneral, 'Ya se reabrió 2 veces');
    });
  });
}
