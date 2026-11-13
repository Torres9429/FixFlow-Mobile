import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/result.dart';
import '../../../domain/errors/auth_failure.dart';
import '../../models/login_response_model.dart';
import '../../models/perfil_model.dart';
import '../../models/registro_response_model.dart';
import 'traducir_error.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Result<LoginResponseModel>> login(String correo, String password) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>('/auth/login', data: {'correo': correo, 'password': password});
      return Result.ok(LoginResponseModel.fromJson(res.data!));
    } catch (e) {
      // En el login, un 401 son credenciales malas o cuenta inactiva (contrato-api, A1)
      if (e is DioException && e.response?.statusCode == 401) return const Result.error(CredencialesInvalidas());
      return Result.error(traducirError(e));
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
        data: {'nombre': nombre, 'apellidos': apellidos, 'correo': correo, 'password': password},
      );
      return Result.ok(RegistroResponseModel.fromJson(res.data!));
    } catch (e) {
      // En el registro, el único conflicto posible es el correo repetido (contrato-api, A2)
      if (e is DioException && e.response?.statusCode == 409) return const Result.error(CorreoDuplicado());
      return Result.error(traducirError(e));
    }
  }

  /// Revoca el refresh token en el back. Si falla no importa: la sesión local se borra igual.
  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post<void>('/auth/logout', data: {'refreshToken': refreshToken});
    } catch (e) {
      debugPrint('[FixFlow] No se pudo cerrar sesión en el servidor: $e');
    }
  }

  Future<Result<PerfilModel>> miPerfil() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/usuarios/me');
      return Result.ok(PerfilModel.fromJson(res.data!));
    } catch (e) {
      return Result.error(traducirError(e));
    }
  }

  Future<Result<PerfilModel>> actualizarPerfil({required String nombre, required String apellidos}) async {
    try {
      final res = await _dio.put<Map<String, dynamic>>(
        '/usuarios/me',
        data: {'nombre': nombre, 'apellidos': apellidos},
      );
      return Result.ok(PerfilModel.fromJson(res.data!));
    } catch (e) {
      return Result.error(traducirError(e));
    }
  }

  Future<Result<String?>> cambiarPassword({required String actual, required String nueva}) async {
    try {
      final res = await _dio.patch<Map<String, dynamic>>(
        '/usuarios/me/password',
        data: {'actual': actual, 'nueva': nueva},
      );
      return Result.ok(res.data?['text'] as String?);
    } catch (e) {
      return Result.error(traducirError(e));
    }
  }
}
