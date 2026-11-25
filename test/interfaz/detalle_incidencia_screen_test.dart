// Test tipo Interfaz: se prueba una pantalla, lo que se ve y se toca

import 'package:fix_flow/core/result.dart';
import 'package:fix_flow/domain/entities/estado_incidencia.dart';
import 'package:fix_flow/domain/entities/evento_historial.dart';
import 'package:fix_flow/domain/entities/incidencia_detalle.dart';
import 'package:fix_flow/domain/entities/incidencia_resumen.dart';
import 'package:fix_flow/domain/entities/prioridad.dart';
import 'package:fix_flow/domain/repositories/direccion_repository.dart';
import 'package:fix_flow/presentation/incidencia/detalle_incidencia_screen.dart';
import 'package:fix_flow/presentation/incidencia/detalle_incidencia_viewmodel.dart';
import 'package:fix_flow/presentation/incidencia/vista_detalle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:fix_flow/presentation/core/theme/app_theme.dart';
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
    EstadoIncidencia estado = EstadoIncidencia.asignada,
    String? fotoUrl,
    int numReaperturas = 0,
  }) =>
      IncidenciaDetalle(
        resumen: IncidenciaResumen(
          id: id,
          folio: 'FX-2026-000101',
          tipo: 'Bache',
          tipoCodigo: 'BACHE',
          estado: estado,
          prioridad: Prioridad.alta,
          motivoPrioridad: 'Prioridad alta',
          latitud: 18.922,
          longitud: -99.234,
          fechaCreacion: DateTime(2026, 11, 1, 10, 30),
          ultimaActualizacion: DateTime(2026, 11, 2, 11, 0),
          fotoUrl: fotoUrl,
        ),
        descripcion: 'Bache profundo en el pavimento.',
        numReaperturas: numReaperturas,
        ciudadano: 'Ana López',
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
    required VistaDetalle vista,
    required DetalleIncidenciaViewModel vm,
  }) =>
      MaterialApp(
        theme: AppTheme.light,
        home: ChangeNotifierProvider<DetalleIncidenciaViewModel>.value(
          value: vm,
          child: const DetalleIncidenciaScreen(),
        ),
      );

  group('HU-11: Ficha informativa de detalle en pantalla C2 (CA-1, CA-4)', () {
    testWidgets('Pantalla C2 renderiza folio, chip de estado, tipo y dirección', (tester) async {
      configurarPantallaGrande(tester);
      when(() => mockIncidencias.detalle(101)).thenAnswer((_) async => Result.ok(crearDetalle()));
      when(() => mockIncidencias.historial(101)).thenAnswer((_) async => const Result.ok([]));
      when(() => mockDireccion.direccion(any(), any())).thenAnswer((_) async => 'Calle Morelos 123');

      final vm = DetalleIncidenciaViewModel(
        id: 101,
        vista: VistaDetalle.ciudadano,
        incidenciasRepository: mockIncidencias,
        direccionRepository: mockDireccion,
        operativoRepository: mockOperativo,
        reportesRepository: MockReportesCiudadanoRepository(),
      );

      await tester.pumpWidget(montarPantalla(vista: VistaDetalle.ciudadano, vm: vm));
      await vm.iniciar();
      await tester.pumpAndSettle();

      expect(find.textContaining('FX-2026-000101'), findsOneWidget);
      expect(find.text('Bache'), findsOneWidget);
      expect(find.text('Asignada'), findsOneWidget);
      expect(find.text('Calle Morelos 123'), findsOneWidget);
    });
  });

  group('HU-15: Diálogo modal de confirmación de inicio de atención', () {
    testWidgets('Al pulsar Iniciar atención aparece diálogo modal; confirmar ejecuta la acción', (tester) async {
      configurarPantallaGrande(tester);
      when(() => mockIncidencias.detalle(101)).thenAnswer(
        (_) async => Result.ok(crearDetalle(estado: EstadoIncidencia.asignada)),
      );
      when(() => mockIncidencias.historial(101)).thenAnswer((_) async => const Result.ok([]));
      when(() => mockDireccion.direccion(any(), any())).thenAnswer((_) async => null);
      when(() => mockOperativo.iniciarAtencion(101)).thenAnswer((_) async => const Result.ok(null));

      final vm = DetalleIncidenciaViewModel(
        id: 101,
        vista: VistaDetalle.operativo,
        incidenciasRepository: mockIncidencias,
        direccionRepository: mockDireccion,
        operativoRepository: mockOperativo,
        reportesRepository: MockReportesCiudadanoRepository(),
      );

      await tester.pumpWidget(montarPantalla(vista: VistaDetalle.operativo, vm: vm));
      await vm.iniciar();
      await tester.pumpAndSettle();

      // Botón Iniciar atención visible para el operativo
      final boton = find.byKey(const Key('detalle_iniciar_atencion'));
      expect(boton, findsOneWidget);

      await tester.tap(boton);
      await tester.pumpAndSettle();

      // Aparece la hoja modal de confirmación
      expect(find.text('¿Iniciar atención?'), findsOneWidget);

      // Confirmar en el diálogo
      final confirmarBtn = find.text('Iniciar atención').last;
      await tester.tap(confirmarBtn);
      await tester.pumpAndSettle();

      verify(() => mockOperativo.iniciarAtencion(101)).called(1);
    });
  });

  group('HU-13: Confirmar resolución en C2 (CA-2, CA-3, CA-4)', () {
    DetalleIncidenciaViewModel crearVm(MockReportesCiudadanoRepository reportes) => DetalleIncidenciaViewModel(
      id: 101,
      vista: VistaDetalle.ciudadano,
      incidenciasRepository: mockIncidencias,
      direccionRepository: mockDireccion,
      operativoRepository: mockOperativo,
      reportesRepository: reportes,
    );

    testWidgets('En Resuelta: pregunta, «Confirmar resolución» con diálogo y «El problema sigue» habilitado', (tester) async {
      configurarPantallaGrande(tester);
      final reportes = MockReportesCiudadanoRepository();
      when(() => mockIncidencias.detalle(101)).thenAnswer(
        (_) async => Result.ok(crearDetalle(estado: EstadoIncidencia.resuelta)),
      );
      when(() => mockIncidencias.historial(101)).thenAnswer((_) async => const Result.ok([]));
      when(() => mockDireccion.direccion(any(), any())).thenAnswer((_) async => null);
      when(() => reportes.confirmarResolucion(101))
          .thenAnswer((_) async => const Result.ok('Solución confirmada; la incidencia quedó cerrada'));

      final vm = crearVm(reportes);
      await tester.pumpWidget(montarPantalla(vista: VistaDetalle.ciudadano, vm: vm));
      await vm.iniciar();
      await tester.pumpAndSettle();

      expect(find.text('¿Se solucionó el problema?'), findsOneWidget);
      // C3 (#72): «El problema sigue» ya está activo desde el detalle
      final problemaSigue = tester.widget<OutlinedButton>(find.byKey(const Key('detalle_problema_sigue')));
      expect(problemaSigue.onPressed, isNotNull);
      expect(find.text('Reabrir el reporte todavía no está disponible.'), findsNothing);

      await tester.tap(find.byKey(const Key('detalle_confirmar_resolucion')));
      await tester.pumpAndSettle();
      expect(find.text('¿Confirmar resolución?'), findsOneWidget);

      await tester.tap(find.text('Confirmar resolución').last);
      await tester.pumpAndSettle();

      verify(() => reportes.confirmarResolucion(101)).called(1);
      expect(find.text('Solución confirmada; la incidencia quedó cerrada'), findsOneWidget);
    });

    testWidgets('Con 2 reaperturas: «El problema sigue» desactivado y aviso de límite', (tester) async {
      configurarPantallaGrande(tester);
      final reportes = MockReportesCiudadanoRepository();
      when(() => mockIncidencias.detalle(101)).thenAnswer(
        (_) async => Result.ok(crearDetalle(estado: EstadoIncidencia.resuelta, numReaperturas: 2)),
      );
      when(() => mockIncidencias.historial(101)).thenAnswer((_) async => const Result.ok([]));
      when(() => mockDireccion.direccion(any(), any())).thenAnswer((_) async => null);

      final vm = crearVm(reportes);
      await tester.pumpWidget(montarPantalla(vista: VistaDetalle.ciudadano, vm: vm));
      await vm.iniciar();
      await tester.pumpAndSettle();

      final problemaSigue = tester.widget<OutlinedButton>(find.byKey(const Key('detalle_problema_sigue')));
      expect(problemaSigue.onPressed, isNull);
      expect(
        find.text('Ya usaste las 2 reaperturas de este reporte; crea uno nuevo.'),
        findsOneWidget,
      );
    });

    testWidgets('En Cerrada no hay barra de acciones', (tester) async {
      configurarPantallaGrande(tester);
      when(() => mockIncidencias.detalle(101)).thenAnswer(
        (_) async => Result.ok(crearDetalle(estado: EstadoIncidencia.cerrada)),
      );
      when(() => mockIncidencias.historial(101)).thenAnswer((_) async => const Result.ok([]));
      when(() => mockDireccion.direccion(any(), any())).thenAnswer((_) async => null);

      final vm = crearVm(MockReportesCiudadanoRepository());
      await tester.pumpWidget(montarPantalla(vista: VistaDetalle.ciudadano, vm: vm));
      await vm.iniciar();
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('detalle_confirmar_resolucion')), findsNothing);
      expect(find.byKey(const Key('detalle_problema_sigue')), findsNothing);
      expect(find.text('¿Se solucionó el problema?'), findsNothing);
    });
  });

  group('HU-22: Botón «Ver todo» en historial de detalle', () {
    testWidgets('Pulsar «Ver todo» despliega todos los eventos cronológicos sin recortar', (tester) async {
      configurarPantallaGrande(tester);
      final eventos = List.generate(
        5,
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

      await tester.pumpWidget(montarPantalla(vista: VistaDetalle.ciudadano, vm: vm));
      await vm.iniciar();
      await tester.pumpAndSettle();

      // Inicialmente se muestra el botón Ver todo porque hay 5 (> 4)
      final verTodoBtn = find.byKey(const Key('historial_ver_todo'));
      expect(verTodoBtn, findsOneWidget);

      await tester.ensureVisible(verTodoBtn);
      await tester.tap(verTodoBtn);
      await tester.pumpAndSettle();

      // Al expandirse, el botón Ver todo desaparece y se muestran todos
      expect(find.byKey(const Key('historial_ver_todo')), findsNothing);
      expect(find.textContaining('Autor 0'), findsOneWidget);
      expect(find.textContaining('Autor 4'), findsOneWidget);
    });
  });
}
