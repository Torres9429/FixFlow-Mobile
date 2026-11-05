// Test tipo Interfaz: se prueba una pantalla, lo que se ve y se toca

import 'dart:convert';
import 'dart:io';

import 'package:fix_flow/core/result.dart';
import 'package:fix_flow/domain/entities/reporte_nuevo.dart';
import 'package:fix_flow/domain/entities/tipo_incidencia.dart';
import 'package:fix_flow/presentation/core/theme/app_theme.dart';
import 'package:fix_flow/presentation/reporte/revision/revision_reporte_screen.dart';
import 'package:fix_flow/presentation/reporte/revision/revision_reporte_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import '../mocks.dart';

void main() {
  late MockEvidenciaRepository mockEvidencia;
  late MockReportesCiudadanoRepository mockReportes;
  late File archivoFotoTemp;

  const bache = TipoIncidencia(
    id: '1',
    nombre: 'Bache',
    codigo: 'BACHE',
    orientacion: OrientacionFoto.suelo,
  );

  ReporteNuevo crearReporte({
    TipoIncidencia tipo = bache,
    String descripcion = 'Bache profundo en el carril derecho',
    double latitud = 18.9220,
    double longitud = -99.2340,
    double? inclinacion = 60.0,
    String? rutaFoto,
  }) {
    return ReporteNuevo(
      tipo: tipo,
      descripcion: descripcion,
      latitud: latitud,
      longitud: longitud,
      inclinacion: inclinacion,
      rutaFoto: rutaFoto ?? archivoFotoTemp.path,
      capturadaEn: DateTime(2026, 11, 4, 11, 30),
    );
  }

  setUpAll(() {
    archivoFotoTemp = File('${Directory.systemTemp.path}/test_evidencia_revision.png')
      ..writeAsBytesSync(base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
      ));
    registerFallbackValue(crearReporte());
  });

  tearDownAll(() {
    if (archivoFotoTemp.existsSync()) {
      archivoFotoTemp.deleteSync();
    }
  });

  setUp(() {
    mockEvidencia = MockEvidenciaRepository();
    mockReportes = MockReportesCiudadanoRepository();
    when(() => mockEvidencia.subirFoto(any()))
        .thenAnswer((_) async => const Result.ok('https://res.cloudinary.com/demo/foto.jpg'));
  });

  Widget montarPantalla(RevisionReporteViewModel vm) {
    return MaterialApp(
      theme: AppTheme.light,
      home: ChangeNotifierProvider<RevisionReporteViewModel>.value(
        value: vm,
        child: const RevisionReporteScreen(),
      ),
    );
  }

  void configurarPantallaGrande(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('HU-03: Pantalla de revisión previa al envío (CA-6)', () {
    testWidgets('Se muestran tipo, descripción, foto, ubicación y botón de confirmar antes de enviar',
        (tester) async {
      configurarPantallaGrande(tester);
      final reporte = crearReporte();
      final vm = RevisionReporteViewModel(
        reporte: reporte,
        evidenciaRepository: mockEvidencia,
        reportesRepository: mockReportes,
      );

      await tester.pumpWidget(montarPantalla(vm));
      await tester.pumpAndSettle();

      // Verificar que estamos en la pantalla de revisión
      expect(find.text('Revisar y enviar'), findsOneWidget);

      // Se muestran tipo y descripción
      expect(find.text('Bache'), findsOneWidget);
      expect(find.text('Bache profundo en el carril derecho'), findsOneWidget);

      // Se muestra la etiqueta de evidencia en vivo sobre la foto
      expect(find.text('Evidencia en vivo'), findsOneWidget);

      // Se muestra la sección de ubicación detectada
      expect(find.text('Ubicación detectada'), findsOneWidget);

      // Se muestra el botón de confirmar ("Enviar reporte")
      expect(find.byKey(const Key('reporte_confirmar')), findsOneWidget);
      expect(find.text('Enviar reporte'), findsOneWidget);
    });
  });

  group('HU-05: El ciudadano visualiza la ubicación antes de enviar (CA-4)', () {
    testWidgets('En la pantalla de revisión, se muestran las coordenadas o un mapa con la ubicación',
        (tester) async {
      configurarPantallaGrande(tester);
      final reporte = crearReporte(latitud: 18.9220, longitud: -99.2340);
      final vm = RevisionReporteViewModel(
        reporte: reporte,
        evidenciaRepository: mockEvidencia,
        reportesRepository: mockReportes,
      );

      await tester.pumpWidget(montarPantalla(vm));
      await tester.pumpAndSettle();

      // Verificar que se muestra la tarjeta de ubicación
      expect(find.text('Ubicación detectada'), findsOneWidget);
      // Coordenadas formateadas
      expect(find.textContaining('18.9220° N'), findsOneWidget);
      expect(find.textContaining('99.2340° W'), findsOneWidget);
      expect(find.text('La ubicación se toma del GPS y no se puede editar'), findsOneWidget);
    });
  });

  group('HU-06: Orientación incorrecta → se solicita recaptura (CA-5)', () {
    testWidgets('Si la orientación no coincide con el tipo, se muestra mensaje pidiendo volver a capturar',
        (tester) async {
      configurarPantallaGrande(tester);
      // Bache con 10° (tomado al frente en vez de hacia el suelo)
      final reporteInvalido = crearReporte(inclinacion: 10.0);
      final vm = RevisionReporteViewModel(
        reporte: reporteInvalido,
        evidenciaRepository: mockEvidencia,
        reportesRepository: mockReportes,
      );

      await tester.pumpWidget(montarPantalla(vm));
      await tester.pumpAndSettle();

      // Debe mostrar el mensaje pidiendo volver a capturar hacia el suelo
      expect(find.byKey(const Key('reporte_aviso')), findsOneWidget);
      expect(find.textContaining('hacia el suelo'), findsOneWidget);

      // En lugar del botón "Enviar", debe aparecer "Volver a capturar"
      expect(find.byKey(const Key('reporte_volver_a_capturar')), findsOneWidget);
      expect(find.text('Volver a capturar'), findsOneWidget);
      expect(find.byKey(const Key('reporte_confirmar')), findsNothing);
    });
  });

  group('HU-08: Validar evidencia del reporte en interfaz (CA-5, CA-6, RN-12)', () {
    testWidgets('Evidencia que no cumple condiciones → botón de enviar queda bloqueado y se solicita recaptura',
        (tester) async {
      configurarPantallaGrande(tester);
      // Sin lectura de acelerómetro (null)
      final reporteSinAcelerometro = crearReporte(inclinacion: null);
      final vm = RevisionReporteViewModel(
        reporte: reporteSinAcelerometro,
        evidenciaRepository: mockEvidencia,
        reportesRepository: mockReportes,
      );

      await tester.pumpWidget(montarPantalla(vm));
      await tester.pumpAndSettle();

      // Aparece aviso de evidencia incompleta y botón "Volver a capturar"
      expect(find.byKey(const Key('reporte_aviso')), findsOneWidget);
      expect(find.textContaining('inclinación'), findsOneWidget);
      expect(find.byKey(const Key('reporte_volver_a_capturar')), findsOneWidget);
      expect(find.byKey(const Key('reporte_confirmar')), findsNothing);
    });

    testWidgets('El reporte no se envía hasta cumplir todos los requisitos (RN-12)',
        (tester) async {
      configurarPantallaGrande(tester);
      final reporteIncompleto = crearReporte(inclinacion: null);
      final vm = RevisionReporteViewModel(
        reporte: reporteIncompleto,
        evidenciaRepository: mockEvidencia,
        reportesRepository: mockReportes,
      );

      await tester.pumpWidget(montarPantalla(vm));
      await tester.pumpAndSettle();

      // Intentar enviar directamente desde el ViewModel con evidencia incompleta
      await vm.enviar();

      // Ningún servicio de subida ni creación fue llamado
      verifyNever(() => mockEvidencia.subirFoto(any()));
      verifyNever(() => mockReportes.crear(any(), any()));
      expect(vm.creado, isNull);
    });
  });
}
