// Test tipo Unitarias: se prueba una clase o función sin pantalla y sin red real

import 'package:fix_flow/core/result.dart';
import 'package:fix_flow/domain/entities/estado_incidencia.dart';
import 'package:fix_flow/domain/entities/incidencia_resumen.dart';
import 'package:fix_flow/domain/entities/pagina.dart';
import 'package:fix_flow/domain/entities/prioridad.dart';
import 'package:fix_flow/presentation/ciudadano/mis_reportes/mis_reportes_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks.dart';

void main() {
  late MockAuthRepository auth;

  setUp(() {
    auth = MockAuthRepository();
    when(() => auth.nombreUsuario()).thenAnswer((_) async => 'Ana');
  });

  group('HU-10: Consultar mis reportes - Paginación incremental', () {
    test('Paginación incremental: cargarMas() solicita la página siguiente y concatena resultados', () async {
      final repo = MockReportesCiudadanoRepository();

      final r1 = IncidenciaResumen(
        id: 1,
        folio: 'FX-001',
        tipo: 'Bache',
        tipoCodigo: 'BACHE',
        estado: EstadoIncidencia.pendiente,
        prioridad: Prioridad.alta,
        motivoPrioridad: 'Prioridad alta',
        latitud: 18.92,
        longitud: -99.23,
        fechaCreacion: DateTime(2026, 11, 5),
        ultimaActualizacion: DateTime(2026, 11, 5),
      );
      final r2 = IncidenciaResumen(
        id: 2,
        folio: 'FX-002',
        tipo: 'Fuga',
        tipoCodigo: 'FUGA',
        estado: EstadoIncidencia.asignada,
        prioridad: Prioridad.media,
        motivoPrioridad: 'Prioridad media',
        latitud: 18.92,
        longitud: -99.23,
        fechaCreacion: DateTime(2026, 11, 5),
        ultimaActualizacion: DateTime(2026, 11, 5),
      );

      when(() => repo.misReportes(estado: any(named: 'estado'), pagina: 0)).thenAnswer(
        (_) async => Result.ok(Pagina(contenido: [r1], numero: 0, totalPaginas: 2)),
      );
      when(() => repo.misReportes(estado: any(named: 'estado'), pagina: 1)).thenAnswer(
        (_) async => Result.ok(Pagina(contenido: [r2], numero: 1, totalPaginas: 2)),
      );

      final vm = MisReportesViewModel(reportesRepository: repo, authRepository: auth);
      await vm.iniciar();
      expect(vm.reportes, hasLength(1));

      await vm.cargarMas();
      expect(vm.reportes, hasLength(2));
      expect(vm.reportes.last.id, 2);

      // Ya en la última página: cargarMas() no vuelve a llamar al repositorio
      await vm.cargarMas();
      verify(() => repo.misReportes(estado: any(named: 'estado'), pagina: 1)).called(1);
    });
  });

  group('HU-14: Consultar incidencias asignadas - Filtrado', () {
    test('Cambio de filtro actualiza estado y recarga lista', () async {
      final repo = MockReportesCiudadanoRepository();

      final pendiente = IncidenciaResumen(
        id: 1,
        folio: 'FX-001',
        tipo: 'Bache',
        tipoCodigo: 'BACHE',
        estado: EstadoIncidencia.pendiente,
        prioridad: Prioridad.alta,
        motivoPrioridad: 'Prioridad alta',
        latitud: 18.92,
        longitud: -99.23,
        fechaCreacion: DateTime(2026, 11, 5),
        ultimaActualizacion: DateTime(2026, 11, 5),
      );

      when(() => repo.misReportes(estado: null, pagina: any(named: 'pagina'))).thenAnswer(
        (_) async => Result.ok(Pagina(contenido: [pendiente], numero: 0, totalPaginas: 1)),
      );
      when(() => repo.misReportes(estado: EstadoIncidencia.resuelta, pagina: any(named: 'pagina'))).thenAnswer(
        (_) async => const Result.ok(Pagina(contenido: [], numero: 0, totalPaginas: 1)),
      );

      final vm = MisReportesViewModel(reportesRepository: repo, authRepository: auth);
      await vm.iniciar();
      expect(vm.reportes, hasLength(1));
      expect(vm.filtro, isNull);

      await vm.cambiarFiltro(EstadoIncidencia.resuelta);
      expect(vm.filtro, EstadoIncidencia.resuelta);
      verify(() => repo.misReportes(estado: EstadoIncidencia.resuelta, pagina: any(named: 'pagina'))).called(1);
    });
  });
}
