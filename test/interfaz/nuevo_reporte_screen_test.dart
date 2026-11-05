// Test tipo Interfaz: se prueba una pantalla, lo que se ve y se toca

import 'dart:io';

import 'package:fix_flow/core/result.dart';
import 'package:fix_flow/data/repositories/fake_incidence_type_repository.dart';
import 'package:fix_flow/domain/repositories/evidencia_repository.dart';
import 'package:fix_flow/domain/repositories/incidence_type_repository.dart';
import 'package:fix_flow/domain/repositories/inclinacion_repository.dart';
import 'package:fix_flow/domain/repositories/reportes_ciudadano_repository.dart';
import 'package:fix_flow/presentation/core/theme/app_theme.dart';
import 'package:fix_flow/presentation/reporte/nuevo_reporte_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
// ignore: depend_on_referenced_packages
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:mocktail/mocktail.dart';
// ignore: depend_on_referenced_packages
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:provider/provider.dart';

import '../mocks.dart';

class MockGeolocatorPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements GeolocatorPlatform {}

class MockImagePickerPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements ImagePickerPlatform {}

class FakeImagePickerOptions extends Fake implements ImagePickerOptions {}

void main() {
  late MockGeolocatorPlatform mockGeolocator;
  late MockImagePickerPlatform mockImagePicker;
  late MockInclinacionRepository mockInclinacion;
  late MockEvidenciaRepository mockEvidencia;
  late MockReportesCiudadanoRepository mockReportes;
  late File archivoFotoTemp;

  final posicionValida = Position(
    latitude: 18.9220,
    longitude: -99.2340,
    timestamp: DateTime(2026, 11, 4),
    accuracy: 5.0,
    altitude: 0.0,
    altitudeAccuracy: 0.0,
    heading: 0.0,
    headingAccuracy: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0,
  );

  setUpAll(() {
    archivoFotoTemp = File('${Directory.systemTemp.path}/test_foto_nuevo_reporte.jpg')
      ..writeAsBytesSync([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46]);
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

    mockImagePicker = MockImagePickerPlatform();
    ImagePickerPlatform.instance = mockImagePicker;
    when(() => mockImagePicker.getLostData()).thenAnswer((_) async => LostDataResponse.empty());

    mockInclinacion = MockInclinacionRepository();
    when(() => mockInclinacion.leerInclinacion()).thenAnswer((_) async => 60.0);

    mockEvidencia = MockEvidenciaRepository();
    when(() => mockEvidencia.subirFoto(any()))
        .thenAnswer((_) async => const Result.ok('https://res.cloudinary.com/demo/foto.jpg'));

    mockReportes = MockReportesCiudadanoRepository();
  });

  Widget montarPantalla({IncidenceTypeRepository? tiposRepo}) {
    return MultiProvider(
      providers: [
        Provider<IncidenceTypeRepository>(create: (_) => tiposRepo ?? FakeIncidenceTypeRepository()),
        Provider<InclinacionRepository>.value(value: mockInclinacion),
        Provider<EvidenciaRepository>.value(value: mockEvidencia),
        Provider<ReportesCiudadanoRepository>.value(value: mockReportes),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const NuevoReporteScreen(),
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

  void stubGpsConcedido() {
    when(() => mockGeolocator.isLocationServiceEnabled()).thenAnswer((_) async => true);
    when(() => mockGeolocator.checkPermission()).thenAnswer((_) async => LocationPermission.whileInUse);
    when(() => mockGeolocator.getCurrentPosition(locationSettings: any(named: 'locationSettings')))
        .thenAnswer((_) async => posicionValida);
  }

  void stubGpsRechazado() {
    when(() => mockGeolocator.isLocationServiceEnabled()).thenAnswer((_) async => true);
    when(() => mockGeolocator.checkPermission()).thenAnswer((_) async => LocationPermission.denied);
    when(() => mockGeolocator.requestPermission()).thenAnswer((_) async => LocationPermission.denied);
  }

  group('HU-03: Enviar formulario de reporte sin completar campos obligatorios (CA-1, CA-2)', () {
    testWidgets('Aparece error bajo cada campo vacío y el envío no se ejecuta', (tester) async {
      configurarPantallaGrande(tester);
      stubGpsConcedido();

      await tester.pumpWidget(montarPantalla());
      await tester.pumpAndSettle();

      // Verificar que estamos en Nuevo reporte
      expect(find.text('Nuevo reporte'), findsOneWidget);

      // Tocar "Continuar a captura" sin seleccionar tipo ni escribir descripción
      await tester.ensureVisible(find.byKey(const Key('reporte_revisar_enviar')));
      await tester.tap(find.byKey(const Key('reporte_revisar_enviar')));
      await tester.pumpAndSettle();

      // Debe aparecer error en el tipo y en la descripción
      expect(find.text('Selecciona un tipo de incidencia'), findsOneWidget);
      expect(find.text('Campo obligatorio'), findsOneWidget);

      // La cámara nunca se abrió
      verifyNever(() => mockImagePicker.getImageFromSource(
            source: ImageSource.camera,
            options: any(named: 'options'),
          ));
    });
  });

  group('HU-04: Capturar evidencia fotográfica en vivo en interfaz (CA-3, CA-4)', () {
    testWidgets('Permiso de cámara concedido → se abre la cámara (CA-3)', (tester) async {
      configurarPantallaGrande(tester);
      stubGpsConcedido();

      when(() => mockImagePicker.getImageFromSource(
            source: ImageSource.camera,
            options: any(named: 'options'),
          )).thenAnswer((_) async => XFile(archivoFotoTemp.path));

      await tester.pumpWidget(montarPantalla());
      await tester.pumpAndSettle();

      // Seleccionar tipo "Bache"
      await tester.tap(find.byKey(const Key('tipo_1')));
      await tester.pumpAndSettle();

      // Escribir descripción
      await tester.enterText(find.byKey(const Key('reporte_descripcion')), 'Bache profundo en la esquina');
      await tester.pumpAndSettle();

      // Tocar "Continuar a captura"
      await tester.ensureVisible(find.byKey(const Key('reporte_revisar_enviar')));
      await tester.tap(find.byKey(const Key('reporte_revisar_enviar')));
      await tester.pumpAndSettle();

      // Al conceder el permiso, se abre la cámara en vivo
      verify(() => mockImagePicker.getImageFromSource(
            source: ImageSource.camera,
            options: any(named: 'options'),
          )).called(1);
    });

    testWidgets('Permiso de cámara rechazado → se muestra aviso (CA-4)', (tester) async {
      configurarPantallaGrande(tester);
      stubGpsConcedido();

      when(() => mockImagePicker.getImageFromSource(
            source: ImageSource.camera,
            options: any(named: 'options'),
          )).thenThrow(Exception('Permiso de cámara denegado'));

      await tester.pumpWidget(montarPantalla());
      await tester.pumpAndSettle();

      // Seleccionar tipo "Bache"
      await tester.tap(find.byKey(const Key('tipo_1')));
      await tester.pumpAndSettle();

      // Escribir descripción
      await tester.enterText(find.byKey(const Key('reporte_descripcion')), 'Bache profundo en la esquina');
      await tester.pumpAndSettle();

      // Tocar "Continuar a captura"
      await tester.ensureVisible(find.byKey(const Key('reporte_revisar_enviar')));
      await tester.tap(find.byKey(const Key('reporte_revisar_enviar')));
      await tester.pumpAndSettle();

      // Se muestra aviso indicando que no es posible continuar sin la cámara
      expect(find.text('No se pudo abrir la cámara. Verifica el permiso.'), findsOneWidget);
    });
  });

  group('HU-05: Registrar ubicación automáticamente en interfaz (CA-1, CA-5)', () {
    testWidgets('Permiso de ubicación concedido → se obtienen coordenadas (CA-1)', (tester) async {
      configurarPantallaGrande(tester);
      stubGpsConcedido();

      when(() => mockImagePicker.getImageFromSource(
            source: ImageSource.camera,
            options: any(named: 'options'),
          )).thenAnswer((_) async => XFile(archivoFotoTemp.path));

      await tester.pumpWidget(montarPantalla());
      await tester.pumpAndSettle();

      // Verificar que el GPS se consultó con éxito
      verify(() => mockGeolocator.getCurrentPosition(locationSettings: any(named: 'locationSettings'))).called(1);

      // Llenar formulario y continuar
      await tester.tap(find.byKey(const Key('tipo_1')));
      await tester.enterText(find.byKey(const Key('reporte_descripcion')), 'Bache en el pavimento');
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('reporte_revisar_enviar')));
      await tester.tap(find.byKey(const Key('reporte_revisar_enviar')));
      await tester.pumpAndSettle();

      // La cámara se abre porque la ubicación se obtuvo correctamente
      verify(() => mockImagePicker.getImageFromSource(
            source: ImageSource.camera,
            options: any(named: 'options'),
          )).called(1);
    });

    testWidgets('Permiso de ubicación rechazado → se muestra aviso (CA-5)', (tester) async {
      configurarPantallaGrande(tester);
      stubGpsRechazado();

      await tester.pumpWidget(montarPantalla());
      await tester.pumpAndSettle();

      // Seleccionar tipo y descripción
      await tester.tap(find.byKey(const Key('tipo_1')));
      await tester.enterText(find.byKey(const Key('reporte_descripcion')), 'Bache sin ubicación');
      await tester.pumpAndSettle();

      // Tocar "Continuar a captura"
      await tester.ensureVisible(find.byKey(const Key('reporte_revisar_enviar')));
      await tester.tap(find.byKey(const Key('reporte_revisar_enviar')));
      await tester.pumpAndSettle();

      // Si se rechaza el permiso de ubicación, se muestra aviso de que la ubicación es obligatoria
      expect(
        find.text('La ubicación GPS es obligatoria para enviar el reporte. Actívala e intenta de nuevo.'),
        findsOneWidget,
      );

      // La cámara no se abre sin ubicación
      verifyNever(() => mockImagePicker.getImageFromSource(
            source: ImageSource.camera,
            options: any(named: 'options'),
          ));
    });
  });
}
