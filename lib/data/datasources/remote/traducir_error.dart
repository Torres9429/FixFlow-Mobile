import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../domain/errors/falla_red.dart';

/// Traduce cualquier error de una petición al back a una [FallaRed], para que nada de Dio salga de `data/`.
/// Decide por el tipo de error y el código HTTP, y conserva el `text` del back (contrato-api, Acuerdos).
FallaRed traducirError(Object e) {
  if (e is! DioException) {
    debugPrint('[FixFlow] Respuesta con otra forma: $e');
    // Un cast fallido (TypeError) o un JSON roto (FormatException) al leer la respuesta
    return const RespuestaInvalida();
  }

  return switch (e.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.transformTimeout => const TiempoAgotado(),
    DioExceptionType.badResponse => _porCodigo(e.response?.statusCode, _textoDelBack(e.response?.data)),
    DioExceptionType.unknown when e.error is FormatException => const RespuestaInvalida(),
    DioExceptionType.connectionError ||
    DioExceptionType.badCertificate ||
    DioExceptionType.cancel ||
    DioExceptionType.unknown => const SinConexion(),
  };
}

/// El `text` de la respuesta `{text, type, result}`, si viene.
String? _textoDelBack(Object? data) {
  if (data is! Map) return null;
  final texto = data['text'];
  return texto is String && texto.trim().isNotEmpty ? texto : null;
}

FallaRed _porCodigo(int? codigo, String? mensaje) => switch (codigo) {
  null => const RespuestaInvalida(),
  401 => SesionVencida(mensaje),
  403 => SinPermiso(mensaje),
  404 => NoEncontrado(mensaje),
  409 => Conflicto(mensaje),
  422 => EvidenciaInvalida(mensaje),
  >= 500 => ErrorDelServidor(codigo, mensaje),
  _ => PeticionRechazada(codigo, mensaje),
};
