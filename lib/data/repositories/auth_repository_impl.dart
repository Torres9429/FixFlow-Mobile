import 'package:flutter/foundation.dart';

import '../../core/result.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/errors/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/session_storage.dart';
import '../datasources/remote/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required this._remote, required this._session});

  final AuthRemoteDataSource _remote;
  final SessionStorage _session;

  @override
  Future<Result<Usuario>> iniciarSesion(String correo, String password) async {
    final res = await _remote.login(correo, password);
    switch (res) {
      case Ok(:final value):
        try {
          await _session.guardarToken(value.token);
        } catch (e) {
          debugPrint('[FixFlow] No se pudo guardar el token: $e');
          // Sin token guardado no hay sesión: no se deja entrar
          return const Result.error(ErrorDesconocido());
        }
        return Result.ok(value.toEntity());
      case Error(:final error):
        return Result.error(error);
    }
  }

  @override
  Future<Result<Usuario>> registrar({
    required String nombre,
    required String apellidos,
    required String correo,
    required String password,
  }) async {
    final res = await _remote.registro(
      nombre: nombre,
      apellidos: apellidos,
      correo: correo,
      password: password,
    );
    switch (res) {
      case Ok(:final value):
        try {
          await _session.guardarToken(value.token);
        } catch (e) {
          debugPrint('[FixFlow] No se pudo guardar el token tras registro: $e');
          return const Result.error(ErrorDesconocido());
        }
        return Result.ok(value.toEntity());
      case Error(:final error):
        return Result.error(error);
    }
  }

  @override
  Future<void> cerrarSesion() async {
    try {
      await _session.borrarToken();
    } catch (e) {
      debugPrint('[FixFlow] No se pudo borrar el token: $e');
      // El usuario siempre debe poder salir, aunque falle el almacenamiento
    }
  }
}

