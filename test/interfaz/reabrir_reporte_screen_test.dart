// Test tipo Interfaz: se prueba una pantalla, lo que se ve y se toca

import 'package:fix_flow/core/result.dart';
import 'package:fix_flow/domain/entities/estado_incidencia.dart';
import 'package:fix_flow/domain/entities/incidencia_detalle.dart';
import 'package:fix_flow/domain/entities/incidencia_resumen.dart';
import 'package:fix_flow/domain/entities/prioridad.dart';
import 'package:fix_flow/presentation/ciudadano/reabrir/reabrir_reporte_screen.dart';
import 'package:fix_flow/presentation/ciudadano/reabrir/reabrir_reporte_viewmodel.dart';
import 'package:fix_flow/presentation/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import '../mocks.dart';

void main() {
  IncidenciaDetalle crearDetalle({int numReaperturas = 0}) => IncidenciaDetalle(
    resumen: IncidenciaResumen(
      id: 101,
      folio: 'FX-2026-000101',
      tipo: 'Fuga de agua',
      tipoCodigo: 'FUGA_AGUA',
      estado: EstadoIncidencia.resuelta,
      prioridad: Prioridad.alta,
      motivoPrioridad: 'Tipo de incidencia: Fuga de agua',
      latitud: 18.922,
      longitud: -99.234,
      fechaCreacion: DateTime(2026, 11, 1, 10, 30),
      ultimaActualizacion: DateTime(2026, 11, 2, 11, 0),
      operativo: 'Luis Ramírez',
    ),
    descripcion: 'Fuga visible sobre la banqueta.',
    numReaperturas: numReaperturas,
    descripcionSolucion: 'Se cambió el tramo de tubería dañado.',
    fechaResolucion: DateTime(2026, 11, 2, 10, 0),
    operativoAsignado: 'Luis Ramírez',
  );

  void configurarPantallaGrande(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Widget montarPantalla({
    required ReabrirReporteViewModel vm,
    required IncidenciaDetalle detalle,
  }) =>
      MaterialApp(
        theme: AppTheme.light,
        home: ChangeNotifierProvider<ReabrirReporteViewModel>.value(
          value: vm,
          child: ReabrirReporteScreen(detalle: detalle),
        ),
      );

  group('HU-23 / #72: Reabrir reporte desde C3', () {
    testWidgets('Renderiza la solución anterior, el campo y las notas', (tester) async {
      configurarPantallaGrande(tester);
      final vm = ReabrirReporteViewModel(id: 101, reportesRepository: MockReportesCiudadanoRepository());

      await tester.pumpWidget(montarPantalla(vm: vm, detalle: crearDetalle()));
      await tester.pumpAndSettle();

      expect(find.text('El problema sigue'), findsOneWidget);
      expect(find.text('Solución anterior'), findsOneWidget);
      expect(find.text('Se cambió el tramo de tubería dañado.'), findsOneWidget);
      expect(find.text('¿Qué sigue mal?'), findsOneWidget);
      expect(find.text('0/500'), findsOneWidget);
      expect(find.text('Puedes reabrir un reporte hasta 2 veces'), findsOneWidget);
      expect(find.text('Tu reporte pasará a Reabierta y el personal operativo verá tu motivo'), findsOneWidget);
      expect(find.byKey(const Key('reabrir_enviar')), findsOneWidget);
      expect(find.byKey(const Key('reabrir_cancelar')), findsOneWidget);
    });

    testWidgets('Justificación corta muestra el error y no reabre', (tester) async {
      configurarPantallaGrande(tester);
      final reportes = MockReportesCiudadanoRepository();
      final vm = ReabrirReporteViewModel(id: 101, reportesRepository: reportes);

      await tester.pumpWidget(montarPantalla(vm: vm, detalle: crearDetalle()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('reabrir_justificacion')), 'sigue mal');
      await tester.pump();
      await tester.ensureVisible(find.byKey(const Key('reabrir_enviar')));
      await tester.tap(find.byKey(const Key('reabrir_enviar')));
      await tester.pumpAndSettle();

      expect(find.text('Mínimo 10 caracteres'), findsOneWidget);
      verifyNever(() => reportes.reabrir(any(), any()));
    });

    testWidgets('Justificación válida reabre, vuelve y muestra el snackbar', (tester) async {
      configurarPantallaGrande(tester);
      final reportes = MockReportesCiudadanoRepository();
      when(() => reportes.reabrir(101, 'Sigue saliendo agua'))
          .thenAnswer((_) async => const Result.ok('Reporte reabierto; el personal operativo verá tu motivo'));
      final vm = ReabrirReporteViewModel(id: 101, reportesRepository: reportes);
      final detalle = crearDetalle();

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => context.push('/reabrir', extra: detalle),
                  child: const Text('Abrir'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/reabrir',
            builder: (context, state) => ChangeNotifierProvider<ReabrirReporteViewModel>.value(
              value: vm,
              child: ReabrirReporteScreen(detalle: state.extra! as IncidenciaDetalle),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(MaterialApp.router(theme: AppTheme.light, routerConfig: router));
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('reabrir_justificacion')), 'Sigue saliendo agua');
      await tester.pump();
      await tester.ensureVisible(find.byKey(const Key('reabrir_enviar')));
      await tester.tap(find.byKey(const Key('reabrir_enviar')));
      await tester.pumpAndSettle();

      verify(() => reportes.reabrir(101, 'Sigue saliendo agua')).called(1);
      expect(find.text('Abrir'), findsOneWidget);
      expect(find.text('Reporte reabierto; el personal operativo verá tu motivo'), findsOneWidget);
    });
  });
}
