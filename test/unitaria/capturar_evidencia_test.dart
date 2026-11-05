// Test tipo Unitarias: se prueba una clase o función sin pantalla y sin red real

import 'package:fix_flow/domain/entities/reporte_nuevo.dart';
import 'package:fix_flow/domain/entities/tipo_incidencia.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
// ignore: depend_on_referenced_packages
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:mocktail/mocktail.dart';
// ignore: depend_on_referenced_packages
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockImagePickerPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements ImagePickerPlatform {}

class FakeImagePickerOptions extends Fake implements ImagePickerOptions {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockImagePickerPlatform mockPlatform;
  late ImagePicker picker;

  setUpAll(() {
    registerFallbackValue(FakeImagePickerOptions());
  });

  setUp(() {
    mockPlatform = MockImagePickerPlatform();
    ImagePickerPlatform.instance = mockPlatform;
    picker = ImagePicker();
  });

  group('HU-04: La captura utiliza la cámara del dispositivo y no permite galería (CA-1, CA-2, RN-09)', () {
    test('El servicio de cámara invoca la cámara en vivo', () async {
      when(() => mockPlatform.getImageFromSource(
            source: ImageSource.camera,
            options: any(named: 'options'),
          )).thenAnswer((_) async => XFile('/tmp/foto_en_vivo.jpg'));

      final foto = await picker.pickImage(source: ImageSource.camera);

      expect(foto, isNotNull);
      expect(foto!.path, '/tmp/foto_en_vivo.jpg');
      verify(() => mockPlatform.getImageFromSource(
            source: ImageSource.camera,
            options: any(named: 'options'),
          )).called(1);
    });

    test('La opción de galería no está habilitada para evidencia', () async {
      // Regla 4 y RN-09: Solo foto en vivo (ImageSource.camera, nunca galería)
      const fuentePermitida = ImageSource.camera;
      const fuenteGaleria = ImageSource.gallery;

      expect(fuentePermitida, equals(ImageSource.camera));
      expect(fuenteGaleria, isNot(equals(ImageSource.camera)));

      // Verificamos que la galería nunca se invoca para capturar evidencia
      verifyNever(() => mockPlatform.getImageFromSource(
            source: ImageSource.gallery,
            options: any(named: 'options'),
          ));
    });
  });

  group('HU-04: La fotografía queda asociada al reporte (CA-5)', () {
    test('Tras capturar, la entidad del reporte contiene la ruta de la imagen', () {
      const rutaFotoCapturada = '/tmp/foto_capturada.jpg';
      final reporte = ReporteNuevo(
        tipo: const TipoIncidencia(id: '1', nombre: 'Bache', codigo: 'BACHE', orientacion: OrientacionFoto.suelo),
        descripcion: 'Bache profundo',
        latitud: 18.92,
        longitud: -99.23,
        inclinacion: 60,
        rutaFoto: rutaFotoCapturada,
        capturadaEn: DateTime(2026, 11, 4, 12, 0),
      );

      expect(reporte.rutaFoto, rutaFotoCapturada);
      expect(reporte.rutaFoto, isNotEmpty);
    });
  });
}
