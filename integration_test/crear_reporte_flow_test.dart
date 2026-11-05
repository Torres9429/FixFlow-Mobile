// Test tipo Integración: la app completa en el emulador, con los servicios simulados

import 'dart:convert';
import 'dart:io';

import 'package:fix_flow/app.dart';
import 'package:fix_flow/data/datasources/local/session_storage.dart';
import 'package:fix_flow/data/datasources/remote/fake_auth_remote_datasource.dart';
import 'package:fix_flow/data/repositories/auth_repository_impl.dart';
import 'package:fix_flow/data/repositories/fakes/fake_evidencia_repository.dart';
import 'package:fix_flow/data/repositories/fakes/fake_inclinacion_repository.dart';
import 'package:fix_flow/data/repositories/fakes/fake_reportes_ciudadano_repository.dart';
import 'package:fix_flow/presentation/reporte/enviado/reporte_enviado_screen.dart';
import 'package:fix_flow/presentation/reporte/nuevo_reporte_screen.dart';
import 'package:fix_flow/presentation/reporte/revision/revision_reporte_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
// ignore: depend_on_referenced_packages
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
// ignore: depend_on_referenced_packages
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../test/mocks.dart';

class MockGeolocatorPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements GeolocatorPlatform {}

class MockImagePickerPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements ImagePickerPlatform {}

class FakeImagePickerOptions extends Fake implements ImagePickerOptions {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockGeolocatorPlatform mockGeolocator;
  late MockImagePickerPlatform mockImagePicker;
  late File archivoFotoTemp;

  final posicionCuernavaca = Position(
    latitude: 18.9220,
    longitude: -99.2340,
    timestamp: DateTime(2026, 11, 4),
    accuracy: 5.0,
    altitude: 1500.0,
    altitudeAccuracy: 1.0,
    heading: 0.0,
    headingAccuracy: 1.0,
    speed: 0.0,
    speedAccuracy: 0.0,
  );

  setUpAll(() {
    archivoFotoTemp = File('${Directory.systemTemp.path}/test_flow_foto.png')
      ..writeAsBytesSync(base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
      ));
    registerFallbackValue(ImageSource.camera);
    registerFallbackValue(FakeImagePickerOptions());
  });

  tearDownAll(() {
    if (archivoFotoTemp.existsSync()) {
      archivoFotoTemp.deleteSync();
    }
  });

  setUp(() {
    mockGeolocator = MockGeolocatorPlatform();
    GeolocatorPlatform.instance = mockGeolocator;
    when(() => mockGeolocator.isLocationServiceEnabled()).thenAnswer((_) async => true);
    when(() => mockGeolocator.checkPermission()).thenAnswer((_) async => LocationPermission.whileInUse);
    when(() => mockGeolocator.getCurrentPosition(locationSettings: any(named: 'locationSettings')))
        .thenAnswer((_) async => posicionCuernavaca);

    mockImagePicker = MockImagePickerPlatform();
    ImagePickerPlatform.instance = mockImagePicker;
    when(() => mockImagePicker.getLostData()).thenAnswer((_) async => LostDataResponse.empty());
    when(() => mockImagePicker.getImageFromSource(
          source: ImageSource.camera,
          options: any(named: 'options'),
        )).thenAnswer((_) async => XFile(archivoFotoTemp.path));
  });

  group('HU-03: Flujo completo: crear y enviar un reporte (CA-1 a CA-7)', () {
    testWidgets(
        'Seleccionar tipo → describir → capturar foto → obtener ubicación → revisar → confirmar → se genera un identificador y se muestra confirmación',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final storage = crearStorageEnMemoria();
      final session = SessionStorage(storage);
      final authRepo = AuthRepositoryImpl(remote: FakeAuthRemoteDataSource(), session: session);
      final reportesRepo = FakeReportesCiudadanoRepository();
      final evidenciaRepo = FakeEvidenciaRepository();
      final inclinacionRepo = FakeInclinacionRepository(); // Devuelve 60° (suelo válido)

      await tester.pumpWidget(
        FixFlowApp(
          authRepository: authRepo,
          reportesCiudadanoRepository: reportesRepo,
          evidenciaRepository: evidenciaRepo,
          inclinacionRepository: inclinacionRepo,
        ),
      );
      await tester.pumpAndSettle();

      // PASO 1: Iniciar sesión como ciudadano
      await tester.enterText(find.byKey(const Key('login_correo')), 'ciudadano@fixflow.mx');
      await tester.enterText(find.byKey(const Key('login_password')), FakeAuthRemoteDataSource.passwordDemo);
      await tester.ensureVisible(find.byKey(const Key('login_entrar')));
      await tester.tap(find.byKey(const Key('login_entrar')));
      await tester.pumpAndSettle();

      // PASO 2: Abrir nuevo reporte desde el botón central naranja
      await tester.tap(find.byKey(const Key('boton_reportar')));
      await tester.pumpAndSettle();
      expect(find.byType(NuevoReporteScreen), findsOneWidget);

      // PASO 3: Seleccionar tipo de incidencia (Bache)
      await tester.tap(find.byKey(const Key('tipo_1')));
      await tester.pumpAndSettle();

      // PASO 4: Describir la incidencia (CA-2)
      await tester.enterText(
        find.byKey(const Key('reporte_descripcion')),
        'Bache grande en el carril derecho sobre Av. Morelos',
      );
      await tester.pumpAndSettle();

      // PASO 5: Continuar a captura (obtiene GPS y abre cámara en vivo) (CA-3, CA-4)
      await tester.ensureVisible(find.byKey(const Key('reporte_revisar_enviar')));
      await tester.tap(find.byKey(const Key('reporte_revisar_enviar')));
      await tester.pumpAndSettle();

      // PASO 6: Pantalla de revisión previa al envío (CA-6)
      expect(find.byType(RevisionReporteScreen), findsOneWidget);
      expect(find.text('Bache'), findsOneWidget);
      expect(find.text('Bache grande en el carril derecho sobre Av. Morelos'), findsOneWidget);
      expect(find.text('Ubicación detectada'), findsOneWidget);

      // PASO 7: Confirmar envío (CA-7)
      await tester.ensureVisible(find.byKey(const Key('reporte_confirmar')));
      await tester.tap(find.byKey(const Key('reporte_confirmar')));
      // Esperar subida de foto simulada y creación del reporte
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pumpAndSettle();

      // PASO 8: Se genera un identificador (folio) y se muestra la pantalla de confirmación (B5)
      expect(find.byType(ReporteEnviadoScreen), findsOneWidget);
      expect(find.text('Reporte registrado'), findsOneWidget);
      expect(find.byKey(const Key('reporte_folio')), findsOneWidget);

      // El folio generado contiene el formato esperado (FX-AAAA-NNNNNN)
      final textoFolio = tester.widget<Text>(find.byKey(const Key('reporte_folio'))).data;
      expect(textoFolio, matches(RegExp(r'^FX-\d{4}-\d{6}$')));
    });
  });
}

