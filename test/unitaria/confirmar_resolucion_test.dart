// Test tipo Unitaria: se prueba una parte del código sola, con sus dependencias simuladas

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fix_flow/core/result.dart';
import 'package:fix_flow/data/repositories/reportes_ciudadano_repository_impl.dart';
import 'package:fix_flow/domain/entities/estado_incidencia.dart';
import 'package:fix_flow/domain/entities/evento_historial.dart';
import 'package:fix_flow/domain/entities/incidencia_detalle.dart';
import 'package:fix_flow/domain/entities/incidencia_resumen.dart';
import 'package:fix_flow/domain/entities/prioridad.dart';
import 'package:fix_flow/domain/repositories/direccion_repository.dart';
import 'package:fix_flow/presentation/incidencia/detalle_incidencia_viewmodel.dart';
import 'package:fix_flow/presentation/incidencia/vista_detalle.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks.dart';

class MockDio extends Mock implements Dio {}

class MockDireccionRepository extends Mock implements DireccionRepository {}

void main() {
  group('HU-13 / #71: Confirmar resolución', () {
    late MockIncidenciasRepository incidencias;
    late MockDireccionRepository direccion;
    late MockReportesCiudadanoRepository reportes;

    setUp(() {
      incidencias = MockIncidenciasRepository();
      direccion = MockDireccionRepository();
      reportes = MockReportesCiudadanoRepository();
      when(() => incidencias.historial(97)).thenAnswer((_) async => const Result.ok(<EventoHistorial>[]));
      when(() => direccion.direccion(any(), any())).thenAnswer((_) async => null);
    });

    IncidenciaDetalle detalle(EstadoIncidencia estado) => IncidenciaDetalle(
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
      numReaperturas: 0,
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

    test('ReportesCiudadanoRepositoryImpl envía POST /incidencias/{id}/confirmacion y devuelve el texto del back', () async {
      final dio = MockDio();
      when(() => dio.post<Map<String, dynamic>>('/incidencias/97/confirmacion')).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          data: {'result': null, 'text': 'Solución confirmada; la incidencia quedó cerrada', 'type': 'SUCCESS'},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/incidencias/97/confirmacion'),
        ),
      );

      final res = await ReportesCiudadanoRepositoryImpl(dio).confirmarResolucion(97);

      expect(res, isA<Ok<String>>());
      expect((res as Ok<String>).value, 'Solución confirmada; la incidencia quedó cerrada');
    });

    test('Solo el ciudadano con su reporte en Resuelta puede confirmar (RN-14)', () async {
      when(() => incidencias.detalle(97)).thenAnswer((_) async => Result.ok(detalle(EstadoIncidencia.resuelta)));
      final ciudadano = crearVm(VistaDetalle.ciudadano);
      final admin = crearVm(VistaDetalle.admin);
      await (ciudadano.iniciar(), admin.iniciar()).wait;
      expect(ciudadano.puedeConfirmarResolucion, isTrue);
      expect(admin.puedeConfirmarResolucion, isFalse);

      when(() => incidencias.detalle(97)).thenAnswer((_) async => Result.ok(detalle(EstadoIncidencia.cerrada)));
      final cerrada = crearVm(VistaDetalle.ciudadano);
      await cerrada.iniciar();
      expect(cerrada.puedeConfirmarResolucion, isFalse);
    });

    test('Confirmar llama al repositorio una sola vez y recarga la ficha en Cerrada', () async {
      when(() => incidencias.detalle(97)).thenAnswer((_) async => Result.ok(detalle(EstadoIncidencia.resuelta)));
      final vm = crearVm(VistaDetalle.ciudadano);
      await vm.iniciar();

      // La respuesta tarda: el segundo toque llega mientras el primero sigue en curso
      final respuesta = Completer<Result<String>>();
      when(() => reportes.confirmarResolucion(97)).thenAnswer((_) => respuesta.future);
      final primero = vm.confirmarResolucion();
      expect(vm.confirmando, isTrue);
      final segundo = await vm.confirmarResolucion();
      expect(segundo, isA<Error<String>>());

      when(() => incidencias.detalle(97)).thenAnswer((_) async => Result.ok(detalle(EstadoIncidencia.cerrada)));
      respuesta.complete(const Result.ok('Solución confirmada; la incidencia quedó cerrada'));
      expect(await primero, isA<Ok<String>>());

      verify(() => reportes.confirmarResolucion(97)).called(1);
      expect(vm.confirmando, isFalse);
      expect(vm.puedeConfirmarResolucion, isFalse);
    });
  });
}
