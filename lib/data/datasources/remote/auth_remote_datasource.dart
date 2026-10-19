import 'package:dio/dio.dart';

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
        '/auth/registro',
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

  AuthFailure _mapear(DioException e) => switch (e.response?.statusCode) {
        401 => const CredencialesInvalidas(),
        409 => const CorreoDuplicado(),
        _ when e.type == DioExceptionType.connectionTimeout ||
                e.type == DioExceptionType.receiveTimeout ||
                e.type == DioExceptionType.connectionError =>
          const SinConexion(),
        _ => const ErrorDesconocido(),
      };
}

