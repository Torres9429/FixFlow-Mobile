import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/result.dart';
import '../../../domain/errors/auth_failure.dart';
import '../../models/login_response_model.dart';
import '../../models/registro_response_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Result<LoginResponseModel>> login(String correo, String password) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'correo': correo, 'password': password},
      );
      return Result.ok(LoginResponseModel.fromJson(res.data!));
    } on DioException catch (e) {
      return Result.error(_mapear(e));
    } catch (_) {
      // Respuesta con un formato inesperado
      return const Result.error(ErrorDesconocido());
    }
  }

  Future<Result<RegistroResponseModel>> registro({
    required String nombre,
    required String apellidos,
    required String correo,
    required String password,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/usuarios/registro',
        data: {
          'nombre': nombre,
          'apellidos': apellidos,
          'correo': correo,
          'password': password,
        },
      );
      return Result.ok(RegistroResponseModel.fromJson(res.data!));
    } on DioException catch (e) {
      return Result.error(_mapear(e));
    } catch (_) {
      return const Result.error(ErrorDesconocido());
    }
  }

  AuthFailure _mapear(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;
    String? msg;
    if (data is Map<String, dynamic>) {
      msg = (data['text'] ?? data['mensaje'] ?? data['message'] ?? data['error'])?.toString().toLowerCase();
    }
    if (statusCode == 409 ||
        (msg != null &&
            (msg.contains('registrado') ||
                msg.contains('duplicado') ||
                msg.contains('ya existe')))) {
      return const CorreoDuplicado();
    }
    if (statusCode == 401) {
      return const CredencialesInvalidas();
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const SinConexion();
    }
    return const ErrorDesconocido();
  }

  /// Revoca el refresh token en el back. Si falla no importa: la sesión local se borra igual.
  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post<void>('/auth/logout', data: {'refreshToken': refreshToken});
    } catch (e) {
      debugPrint('[FixFlow] No se pudo cerrar sesión en el servidor: $e');
    }
  }

}
