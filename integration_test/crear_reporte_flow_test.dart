// Test tipo Integración: la app completa en el emulador, con los servicios simulados

import 'dart:async';
import 'dart:convert';
import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:fix_flow/app.dart';
import 'package:fix_flow/data/datasources/local/session_storage.dart';
import 'package:fix_flow/data/datasources/remote/fake_auth_remote_datasource.dart';
import 'package:fix_flow/data/repositories/auth_repository_impl.dart';
import 'package:fix_flow/data/repositories/fakes/fake_evidencia_repository.dart';
import 'package:fix_flow/data/repositories/fakes/fake_inclinacion_repository.dart';
import 'package:fix_flow/data/repositories/fakes/fake_reportes_ciudadano_repository.dart';
import 'package:fix_flow/presentation/reporte/camara/camara_orientacion_screen.dart';
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

/// Cámara trasera simulada: se inicializa al momento y el disparo devuelve [foto].
/// Solo implementa lo que usan `CameraController.initialize()` y `takePicture()`.
class FakeCameraPlatform extends Fake with MockPlatformInterfaceMixin implements CameraPlatform {
  FakeCameraPlatform(this.foto);

  final String foto;

  @override
  Future<List<CameraDescription>> availableCameras() async => const [
    CameraDescription(name: '0', lensDirection: CameraLensDirection.back, sensorOrientation: 90),
  ];

  @override
  Stream<DeviceOrientationChangedEvent> onDeviceOrientationChanged() => const Stream.empty();

  @override
  Future<int> createCameraWithSettings(CameraDescription cameraDescription, MediaSettings mediaSettings) async => 1;

  @override
  Stream<CameraInitializedEvent> onCameraInitialized(int cameraId) => Stream.value(
    const CameraInitializedEvent(1, 640, 480, ExposureMode.auto, false, FocusMode.auto, false),
  );

  @override
  // Nunca emite: el controller hace `.first` sobre este stream y uno vacío lanzaría «No element»
  Stream<CameraErrorEvent> onCameraError(int cameraId) => Completer<CameraErrorEvent>().future.asStream();

  @override
  Future<void> initializeCamera(int cameraId, {ImageFormatGroup imageFormatGroup = ImageFormatGroup.unknown}) async {}

  @override
  Future<XFile> takePicture(int cameraId) async => XFile(foto);

  @override
  Widget buildPreview(int cameraId) => const ColoredBox(color: Colors.black);

  @override
  Future<void> dispose(int cameraId) async {}
}

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

    CameraPlatform.instance = FakeCameraPlatform(archivoFotoTemp.path);
  });

  Future<void> recorrerReporte(WidgetTester tester, {required bool conSensor}) async {
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
      // Con sensor devuelve 60° (suelo válido); sin sensor, B2 avisa y la cámara abre en B3e
      final inclinacionRepo = FakeInclinacionRepository(conSensor: conSensor);

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

      if (!conSensor) expect(find.byKey(const Key('aviso_sin_sensor')), findsOneWidget);

      // PASO 5: Continuar a captura: se abre la cámara en vivo de la app (CA-3, CA-4)
      await tester.ensureVisible(find.byKey(const Key('reporte_revisar_enviar')));
      await tester.tap(find.byKey(const Key('reporte_revisar_enviar')));
      await tester.pumpAndSettle();
      expect(find.byType(CamaraOrientacionScreen), findsOneWidget);

      // Tomar la foto: con sensor, Bache a 60° está en la zona válida; sin sensor, el disparador siempre está activo
      await tester.tap(find.byKey(const Key('disparador')));
      await tester.pumpAndSettle();

      // PASO 6: Pantalla de revisión previa al envío (CA-6)
      expect(find.byType(RevisionReporteScreen), findsOneWidget);
      expect(find.text('Bache'), findsOneWidget);
      expect(find.text('Bache grande en el carril derecho sobre Av. Morelos'), findsOneWidget);
      expect(find.text('Ubicación detectada'), findsOneWidget);
      if (!conSensor) expect(find.textContaining('Sin sensor de inclinación'), findsOneWidget);

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
  }

  group('HU-03: Flujo completo: crear y enviar un reporte (CA-1 a CA-7)', () {
    testWidgets(
      'Seleccionar tipo → describir → capturar foto → obtener ubicación → revisar → confirmar → se genera un identificador y se muestra confirmación',
      (tester) => recorrerReporte(tester, conSensor: true),
    );

    testWidgets(
      'HU-06: teléfono sin acelerómetro → aviso en B2, cámara sin guía y el reporte se envía (CA-7, RN-11)',
      (tester) => recorrerReporte(tester, conSensor: false),
    );
  });
}

