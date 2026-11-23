// Test tipo Unitarias: se prueba una clase o función sin pantalla y sin red real

import 'package:fix_flow/core/result.dart';
import 'package:fix_flow/domain/entities/estado_incidencia.dart';
import 'package:fix_flow/domain/entities/evento_historial.dart';
import 'package:fix_flow/domain/entities/incidencia_detalle.dart';
import 'package:fix_flow/domain/entities/incidencia_resumen.dart';
import 'package:fix_flow/domain/entities/prioridad.dart';
import 'package:fix_flow/domain/errors/falla_red.dart';
import 'package:fix_flow/domain/repositories/direccion_repository.dart';
import 'package:fix_flow/presentation/core/estado_consulta.dart';
import 'package:fix_flow/presentation/incidencia/detalle_incidencia_viewmodel.dart';
import 'package:fix_flow/presentation/incidencia/vista_detalle.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks.dart';

class MockDireccionRepository extends Mock implements DireccionRepository {}

void main() {
  late MockIncidenciasRepository mockIncidencias;
  late MockDireccionRepository mockDireccion;
  late MockOperativoRepository mockOperativo;

  setUp(() {
    mockIncidencias = MockIncidenciasRepository();
    mockDireccion = MockDireccionRepository();
    mockOperativo = MockOperativoRepository();
  });

  IncidenciaDetalle crearDetalle({
    int id = 101,
    String ciudadano = 'Ana López',
    double lat = 18.922,
    double lng = -99.234,
  }) =>
      IncidenciaDetalle(
        resumen: IncidenciaResumen(
          id: id,
          folio: 'FX-2026-000101',
          tipo: 'Bache',
          tipoCodigo: 'BACHE',
          estado: EstadoIncidencia.enProceso,
          prioridad: Prioridad.alta,
          motivoPrioridad: 'Prioridad alta',
          latitud: lat,
          longitud: lng,
          fechaCreacion: DateTime(2026, 11, 1),
          ultimaActualizacion: DateTime(2026, 11, 2),
        ),
        descripcion: 'Bache profundo en el carril derecho.',
        numReaperturas: 0,
        ciudadano: ciudadano,
        operativoAsignado: 'Luis Ramírez',
      );

  group('HU-11: Consultar estado de una incidencia', () {
    test('Carga paralela de detalle e historial con geocodificación de dirección (CA-1, CA-2)', () async {
      final detalle = crearDetalle();
      final eventos = [
        EventoHistorial(
          id: 1,
          accion: AccionHistorial.creada,
          estadoNuevo: EstadoIncidencia.pendiente,
          realizadoPor: 'Ana López',
          fecha: DateTime(2026, 11, 1, 10, 0),
        ),
      ];

      when(() => mockIncidencias.detalle(101)).thenAnswer((_) async => Result.ok(detalle));
      when(() => mockIncidencias.historial(101)).thenAnswer((_) async => Result.ok(eventos));
      when(() => mockDireccion.direccion(18.922, -99.234)).thenAnswer((_) async => 'Av. Central 123');

      final vm = DetalleIncidenciaViewModel(
        id: 101,
        vista: VistaDetalle.ciudadano,
        incidenciasRepository: mockIncidencias,
        direccionRepository: mockDireccion,
        operativoRepository: mockOperativo,
        reportesRepository: MockReportesCiudadanoRepository(),
      );

      await vm.iniciar();

      expect(vm.estado, isA<Listo<DetalleConHistorial>>());
      final datos = (vm.estado as Listo<DetalleConHistorial>).datos;
      expect(datos.detalle.resumen.folio, 'FX-2026-000101');
      expect(vm.direccion, 'Av. Central 123');
      verify(() => mockIncidencias.detalle(101)).called(1);
      verify(() => mockIncidencias.historial(101)).called(1);
      verify(() => mockDireccion.direccion(18.922, -99.234)).called(1);
    });

    test('Protección de datos del ciudadano según el rol (RNF-04)', () {
      final vmAdmin = DetalleIncidenciaViewModel(
        id: 101,
        vista: VistaDetalle.admin,
        incidenciasRepository: mockIncidencias,
        direccionRepository: mockDireccion,
        operativoRepository: mockOperativo,
        reportesRepository: MockReportesCiudadanoRepository(),
      );
      final vmOperativo = DetalleIncidenciaViewModel(
        id: 101,
        vista: VistaDetalle.operativo,
        incidenciasRepository: mockIncidencias,
        direccionRepository: mockDireccion,
        operativoRepository: mockOperativo,
        reportesRepository: MockReportesCiudadanoRepository(),
      );
      final vmCiudadano = DetalleIncidenciaViewModel(
        id: 101,
        vista: VistaDetalle.ciudadano,
        incidenciasRepository: mockIncidencias,
        direccionRepository: mockDireccion,
        operativoRepository: mockOperativo,
        reportesRepository: MockReportesCiudadanoRepository(),
      );

      expect(vmAdmin.mostrarCiudadano, isTrue);
      expect(vmOperativo.mostrarCiudadano, isFalse);
      expect(vmCiudadano.mostrarCiudadano, isFalse);
    });

    test('Manejo de fallo de red en consulta de detalle', () async {
      when(() => mockIncidencias.detalle(101)).thenAnswer((_) async => const Result.error(SinConexion()));
      when(() => mockIncidencias.historial(101)).thenAnswer((_) async => const Result.ok([]));

      final vm = DetalleIncidenciaViewModel(
        id: 101,
        vista: VistaDetalle.ciudadano,
        incidenciasRepository: mockIncidencias,
        direccionRepository: mockDireccion,
        operativoRepository: mockOperativo,
        reportesRepository: MockReportesCiudadanoRepository(),
      );

      await vm.iniciar();

      expect(vm.estado, isA<ConError<DetalleConHistorial>>());
      expect((vm.estado as ConError<DetalleConHistorial>).mensaje, contains('Revisa tu internet'));
    });
  });

  group('HU-22: Consultar historial de una incidencia', () {
    test('Historial se ordena de forma cronológica inversa (CA-1, CA-5)', () async {
      final e1 = EventoHistorial(
        id: 1,
        accion: AccionHistorial.creada,
        estadoNuevo: EstadoIncidencia.pendiente,
        realizadoPor: 'Ana',
        fecha: DateTime(2026, 11, 1),
      );
      final e2 = EventoHistorial(
        id: 2,
        accion: AccionHistorial.asignacion,
        estadoNuevo: EstadoIncidencia.asignada,
        realizadoPor: 'Admin',
        fecha: DateTime(2026, 11, 2),
      );
      final e3 = EventoHistorial(
        id: 3,
        accion: AccionHistorial.cambioEstado,
        estadoNuevo: EstadoIncidencia.enProceso,
        realizadoPor: 'Luis',
        fecha: DateTime(2026, 11, 3),
      );

      // El repositorio devuelve la lista cronológica ascendente
      when(() => mockIncidencias.detalle(101)).thenAnswer((_) async => Result.ok(crearDetalle()));
      when(() => mockIncidencias.historial(101)).thenAnswer((_) async => Result.ok([e1, e2, e3]));
      when(() => mockDireccion.direccion(any(), any())).thenAnswer((_) async => null);

      final vm = DetalleIncidenciaViewModel(
        id: 101,
        vista: VistaDetalle.ciudadano,
        incidenciasRepository: mockIncidencias,
        direccionRepository: mockDireccion,
        operativoRepository: mockOperativo,
        reportesRepository: MockReportesCiudadanoRepository(),
      );

      await vm.iniciar();

      final eventos = (vm.estado as Listo<DetalleConHistorial>).datos.historial;
      expect(eventos.first.estadoNuevo, EstadoIncidencia.enProceso);
      expect(eventos.last.estadoNuevo, EstadoIncidencia.pendiente);
    });

    test('Recorte a 3 eventos más recientes si hay más de 4', () async {
      final eventos = List.generate(
        6,
        (i) => EventoHistorial(
          id: i + 1,
          accion: AccionHistorial.cambioEstado,
          estadoNuevo: EstadoIncidencia.enProceso,
          realizadoPor: 'Autor $i',
          fecha: DateTime(2026, 11, i + 1),
        ),
      );

      when(() => mockIncidencias.detalle(101)).thenAnswer((_) async => Result.ok(crearDetalle()));
      when(() => mockIncidencias.historial(101)).thenAnswer((_) async => Result.ok(eventos));
      when(() => mockDireccion.direccion(any(), any())).thenAnswer((_) async => null);

      final vm = DetalleIncidenciaViewModel(
        id: 101,
        vista: VistaDetalle.ciudadano,
        incidenciasRepository: mockIncidencias,
        direccionRepository: mockDireccion,
        operativoRepository: mockOperativo,
        reportesRepository: MockReportesCiudadanoRepository(),
      );

      await vm.iniciar();

      expect(vm.hayMas, isTrue);
      expect(vm.eventosVisibles, hasLength(3));

      vm.mostrarTodo();
      expect(vm.hayMas, isFalse);
      expect(vm.eventosVisibles, hasLength(6));
    });
  });
}
