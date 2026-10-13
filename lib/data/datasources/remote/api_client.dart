import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/config/app_config.dart';
import '../local/session_storage.dart';

/// El único `Dio` que habla con la API de FixFlow.
class ApiClient {
  ApiClient({required SessionStorage session})
      : dio = Dio(BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
          contentType: Headers.jsonContentType,
        )) {
    dio.interceptors.add(InterceptorsWrapper(
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
    ));
    // Sin requestBody para no imprimir contraseñas en la consola
    if (AppConfig.logHttp) dio.interceptors.add(LogInterceptor(responseBody: true));
  }

  final Dio dio;
}
