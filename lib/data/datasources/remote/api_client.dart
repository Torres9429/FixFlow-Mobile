import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/config/app_config.dart';
import '../local/session_storage.dart';

/// El único `Dio` que habla con la API de FixFlow.
class ApiClient {
  ApiClient({required SessionStorage session, this.alExpirarSesion})
      : _session = session,
        dio = Dio(_opciones()),
        // Dio sin interceptores para el refresh y el reintento (evita ciclos y bloqueos)
        _plano = Dio(_opciones()) {
    dio.interceptors.add(QueuedInterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final token = await session.leerToken();
          if (token != null) options.headers['Authorization'] = 'Bearer $token';
        } catch (e) {
          debugPrint('[FixFlow] No se pudo leer el token: $e');
          // Sin token la petición sigue; el back responderá 401 si lo necesita
        }
        // Siempre hay que llamar al handler o la petición se queda colgada
        handler.next(options);
      },
      onError: (e, handler) async {
        final esAuth = e.requestOptions.path.startsWith('/auth/');
        if (e.response?.statusCode != 401 || esAuth) return handler.next(e);

        final token = await _tokenVigente(e.requestOptions);
        if (token == null) {
          await _session.borrarSesion();
          alExpirarSesion?.call();
          return handler.next(e);
        }
        // Repetir la petición original una sola vez con el token nuevo
        final opciones = e.requestOptions..headers['Authorization'] = 'Bearer $token';
        try {
          handler.resolve(await _plano.fetch(opciones));
        } on DioException catch (err) {
          handler.next(err);
        }
      },
    ));
    // Sin requestBody para no imprimir contraseñas en la consola
    if (AppConfig.logHttp) dio.interceptors.add(LogInterceptor(responseBody: true));
  }

  final Dio dio;
  final Dio _plano;
  final SessionStorage _session;

  /// Se llama cuando ya no se pudo renovar: la app debe mandar al login.
  final void Function()? alExpirarSesion;

  static BaseOptions _opciones() => BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    contentType: Headers.jsonContentType,
  );

  /// Si otra petición ya renovó mientras esta esperaba, usa ese token; si no, renueva.
  Future<String?> _tokenVigente(RequestOptions fallida) async {
    final actual = await _session.leerToken();
    if (actual != null && fallida.headers['Authorization'] != 'Bearer $actual') return actual;
    return _renovar();
  }

  Future<String?> _renovar() async {
    final refresh = await _session.leerRefreshToken();
    if (refresh == null) return null;
    try {
      final res = await _plano.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refresh},
      );
      final r = res.data!['result'] as Map<String, dynamic>;
      // Cada refresh token sirve una sola vez: hay que guardar el nuevo
      await _session.guardarSesion(r['jwt'] as String, r['refreshToken'] as String);
      return r['jwt'] as String;
    } catch (e) {
      debugPrint('[FixFlow] No se pudo renovar la sesión: $e');
      return null;
    }
  }
}

