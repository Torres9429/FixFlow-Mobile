// Test tipo Unitarias: se prueba una clase o función sin pantalla y sin red real

import 'package:fix_flow/core/result.dart';
import 'package:fix_flow/data/repositories/fakes/fake_admin_repository.dart';
import 'package:fix_flow/data/repositories/fakes/fake_operativo_repository.dart';
import 'package:fix_flow/data/repositories/fakes/fake_reportes_ciudadano_repository.dart';
import 'package:fix_flow/data/repositories/fakes/fake_ubicacion_repository.dart';
import 'package:fix_flow/domain/entities/coordenada.dart';
import 'package:fix_flow/domain/entities/estado_incidencia.dart';
import 'package:fix_flow/domain/entities/prioridad.dart';
import 'package:fix_flow/domain/errors/falla_red.dart';
import 'package:fix_flow/presentation/admin/panel/panel_viewmodel.dart';
import 'package:fix_flow/presentation/ciudadano/mis_reportes/mis_reportes_viewmodel.dart';
import 'package:fix_flow/presentation/core/estado_consulta.dart';
import 'package:fix_flow/presentation/operativo/asignadas/asignadas_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks.dart';

void main() {
  late MockAuthRepository auth;

  setUp(() {
    auth = MockAuthRepository();
    when(() => auth.nombreUsuario()).thenAnswer((_) async => 'Ana');
  });

  group('HU-10: Mis reportes (B1, C4)', () {
    test('Con reportes: carga el nombre y la lista; el filtro deja solo ese estado', () async {
      final vm = MisReportesViewModel(reportesRepository: FakeReportesCiudadanoRepository(), authRepository: auth);

      await vm.iniciar();
      expect(vm.nombre, 'Ana');
      expect(vm.reportes, hasLength(4));
      expect(vm.sinReportes, isFalse);

      await vm.cambiarFiltro(EstadoIncidencia.resuelta);
      expect(vm.reportes.map((r) => r.estado), everyElement(EstadoIncidencia.resuelta));
    });

    test('Sin ningún reporte → se muestra C4', () async {
      final vm = MisReportesViewModel(
        reportesRepository: FakeReportesCiudadanoRepository(reportes: const []),
        authRepository: auth,
      );

      await vm.iniciar();

      expect(vm.sinReportes, isTrue);
    });
  });

  group('HU-14: Mis asignadas (D1)', () {
    test('Resumen en texto y distancia desde el GPS', () async {
      final vm = AsignadasViewModel(
        operativoRepository: FakeOperativoRepository(),
        ubicacionRepository: FakeUbicacionRepository(),
        authRepository: auth,
      );

      await vm.iniciar();

      expect(vm.resumen, '4 activas · 2 de prioridad alta · 1 reabierta');
      expect(vm.asignadas.first.prioridad, Prioridad.alta);
      expect(vm.distancia(vm.asignadas.first), matches(RegExp(r'^a \d+\.\d km$')));
    });

    test('Distancia en línea recta entre dos puntos', () {
      const centro = Coordenada(18.9220, -99.2340);
      // Unos 1.1 km al norte
      expect(centro.distanciaKm(const Coordenada(18.9320, -99.2340)), closeTo(1.11, 0.02));
    });
  });

  group('HU-19 y HU-20: Panel del admin (E1)', () {
    test('Carga las cifras y solo las de prioridad alta sin asignar', () async {
      final vm = PanelViewModel(adminRepository: FakeAdminRepository(), authRepository: auth);

      await vm.iniciar();

      final datos = (vm.estado as Listo<DatosPanel>).datos;
      expect(datos.indicadores.registradas, 128);
      expect(datos.prioritarias, isNotEmpty);
      expect(datos.prioritarias, hasLength(lessThanOrEqualTo(PanelViewModel.maxPrioritarias)));
      expect(
        datos.prioritarias.every((i) => i.prioridad == Prioridad.alta && i.estado == EstadoIncidencia.pendiente),
        isTrue,
      );
    });

    test('Sin conexión → mensaje de error y sin cifras', () async {
      final repo = MockAdminRepository();
      when(() => repo.indicadores()).thenAnswer((_) async => const Result.error(SinConexion()));
      when(
        () => repo.incidencias(
          estado: any(named: 'estado'),
          prioridad: any(named: 'prioridad'),
          pagina: any(named: 'pagina'),
          tamano: any(named: 'tamano'),
        ),
      ).thenAnswer((_) async => const Result.error(SinConexion()));
      final vm = PanelViewModel(adminRepository: repo, authRepository: auth);

      await vm.iniciar();

      expect(vm.estado, isA<ConError<DatosPanel>>());
      expect((vm.estado as ConError<DatosPanel>).mensaje, contains('Revisa tu internet'));
    });
  });
}
