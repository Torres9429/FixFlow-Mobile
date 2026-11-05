// Test tipo Unitarias: se prueba una clase o función sin pantalla y sin red real

import 'package:dio/dio.dart';
import 'package:fix_flow/data/datasources/remote/traducir_error.dart';
import 'package:fix_flow/domain/errors/falla_red.dart';
import 'package:fix_flow/presentation/core/mensajes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final peticion = RequestOptions(path: '/incidencias');

  DioException conCodigo(int codigo, [Object? data]) => DioException.badResponse(
    statusCode: codigo,
    requestOptions: peticion,
    response: Response(requestOptions: peticion, statusCode: codigo, data: data),
  );

  group('traducirError: de DioException a FallaRed', () {
    test('Timeout → TiempoAgotado', () {
      final e = DioException.receiveTimeout(timeout: const Duration(seconds: 15), requestOptions: peticion);
      expect(traducirError(e), isA<TiempoAgotado>());
    });

    test('422 con el text del back → EvidenciaInvalida con ese mensaje', () {
      final falla = traducirError(
        conCodigo(422, {'text': 'La inclinación no corresponde al tipo', 'type': 'ERROR', 'result': null}),
      );
      expect(falla, isA<EvidenciaInvalida>());
      expect(falla.mensaje, 'La inclinación no corresponde al tipo');
    });

    test('500 → ErrorDelServidor(500)', () {
      final falla = traducirError(conCodigo(500));
      expect(falla, isA<ErrorDelServidor>().having((f) => f.codigo, 'codigo', 500));
    });

    test('JSON con otra forma (TypeError al leerlo) → RespuestaInvalida', () {
      Object? error;
      try {
        // Lo que pasa al leer `result` cuando el back manda otra forma
        ({'result': 'no es un mapa'})['result'] as Map<String, dynamic>;
      } catch (e) {
        error = e;
      }
      expect(traducirError(error!), isA<RespuestaInvalida>());
    });
  });

  group('mensajePara: lo que lee el usuario', () {
    test('Un 409 con text muestra el mensaje del back', () {
      expect(mensajePara(const Conflicto('La incidencia ya fue asignada')), 'La incidencia ya fue asignada');
    });

    test('Un 500 muestra un texto fijo, sin código ni detalles', () {
      final mensaje = mensajePara(const ErrorDelServidor(500, 'NullPointerException en IncidenciaService'));
      expect(mensaje, 'FixFlow tuvo un problema. Intenta más tarde.');
    });
  });
}
