// Test tipo Unitarias: se prueba una clase o función sin pantalla y sin red real

import 'package:fix_flow/core/result.dart';
import 'package:fix_flow/domain/entities/prioridad.dart';
import 'package:fix_flow/domain/entities/reporte_creado.dart';
import 'package:fix_flow/domain/entities/reporte_nuevo.dart';
import 'package:fix_flow/domain/entities/tipo_incidencia.dart';
import 'package:fix_flow/domain/errors/falla_red.dart';
import 'package:fix_flow/domain/validators/evidencia_validator.dart';
import 'package:fix_flow/presentation/reporte/revision/revision_reporte_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks.dart';

void main() {
  const bache = TipoIncidencia(id: '1', nombre: 'Bache', codigo: 'BACHE', orientacion: OrientacionFoto.suelo);

  ReporteNuevo reporte({double? inclinacion = 62}) => ReporteNuevo(
    tipo: bache,
    descripcion: 'Bache grande en el carril derecho',
    latitud: 18.92,
    longitud: -99.23,
    inclinacion: inclinacion,
    rutaFoto: '/tmp/foto.jpg',
    capturadaEn: DateTime(2026, 11, 4, 11, 28),
  );

  final creado = ReporteCreado(
    id: 142,
    folio: 'FX-2026-000142',
    tipo: 'Bache',
    prioridad: Prioridad.media,
    fechaCreacion: DateTime(2026, 11, 4, 11, 30),
  );

  setUpAll(() => registerFallbackValue(reporte()));

  group('RN-12: validar la evidencia antes de enviar', () {
    test('Sin lectura del acelerómetro → pide volver a capturar', () {
      expect(validarEvidencia(reporte(inclinacion: null)), contains('inclinación'));
    });

    test('Bache (hacia el suelo) tomado al frente, 10° → pide apuntar al suelo', () {
      expect(validarEvidencia(reporte(inclinacion: 10)), contains('hacia el suelo'));
    });

    test('Bache tomado hacia el suelo, 62° → válido', () {
      expect(validarEvidencia(reporte()), isNull);
    });
  });

  group('HU-03: enviar el reporte desde B4', () {
    late MockEvidenciaRepository evidencia;
    late MockReportesCiudadanoRepository reportes;

    setUp(() {
      evidencia = MockEvidenciaRepository();
      reportes = MockReportesCiudadanoRepository();
      when(() => evidencia.subirFoto(any()))
          .thenAnswer((_) async => const Result.ok('https://res.cloudinary.com/x/f.jpg'));
    });

    RevisionReporteViewModel vm() =>
        RevisionReporteViewModel(reporte: reporte(), evidenciaRepository: evidencia, reportesRepository: reportes);

    test('Todo bien → sube la foto una vez y queda el folio para B5', () async {
      when(() => reportes.crear(any(), any())).thenAnswer((_) async => Result.ok(creado));
      final modelo = vm();

      await modelo.enviar();

      expect(modelo.creado?.folio, 'FX-2026-000142');
      verify(() => evidencia.subirFoto('/tmp/foto.jpg')).called(1);
      verify(() => reportes.crear(any(), 'https://res.cloudinary.com/x/f.jpg')).called(1);
    });

    test('El back responde 422 → muestra su texto y pide volver a capturar', () async {
      when(() => reportes.crear(any(), any())).thenAnswer(
        (_) async =>
            const Result.error(EvidenciaInvalida('Para este tipo apunta la cámara hacia el suelo y repite la captura')),
      );
      final modelo = vm();

      await modelo.enviar();

      expect(modelo.pideRepetir, isTrue);
      expect(modelo.error, 'Para este tipo apunta la cámara hacia el suelo y repite la captura');
      expect(modelo.creado, isNull);
    });

    test('Falla el envío y se reintenta → no vuelve a subir la foto (RNF-08)', () async {
      when(() => reportes.crear(any(), any())).thenAnswer((_) async => const Result.error(SinConexion()));
      final modelo = vm();
      await modelo.enviar();
      expect(modelo.error, contains('Revisa tu internet'));

      when(() => reportes.crear(any(), any())).thenAnswer((_) async => Result.ok(creado));
      await modelo.enviar();

      expect(modelo.creado, isNotNull);
      verify(() => evidencia.subirFoto(any())).called(1);
    });
  });
}
