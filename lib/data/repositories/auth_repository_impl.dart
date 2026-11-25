import 'dart:async';

import '../../core/log/bitacora.dart';
import '../../core/result.dart';
import '../../domain/entities/perfil.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/session_storage.dart';
import '../datasources/remote/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this._remote,
    required this._session,
    this._alIniciarSesion,
    this._alCerrarSesion,
  });

  final AuthRemoteDataSource _remote;
  final SessionStorage _session;

  /// Push (FCM): registrar y borrar el token del teléfono. Se conectan en dependencies.dart
  final Future<void> Function()? _alIniciarSesion;
  final Future<void> Function()? _alCerrarSesion;

  @override
  Future<Result<Usuario>> iniciarSesion(String correo, String password) async {
    final res = await _remote.login(correo, password);

    switch (res) {
      case Ok(:final value):
        try {
          await _session.guardarSesion(value.token, value.refreshToken);
          await _session.guardarNombre(value.nombre);
        } catch (e) {
          Bitacora.error('No se pudo guardar el token', e);
          // Sin token guardado no hay sesión: no se deja entrar
          return Result.error(e);
        }
        // Sin await: el diálogo de permiso no debe frenar la entrada
        final alIniciar = _alIniciarSesion;
        if (alIniciar != null) unawaited(alIniciar());
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
        return Result.ok(value.toEntity());
      case Error(:final error):
        return Result.error(error);
    }
  }

  @override
  Future<void> cerrarSesion() async {
    try {
      // Antes del logout: el DELETE del token de FCM todavía necesita la sesión
      await _alCerrarSesion?.call();
      final refresh = await _session.leerRefreshToken();
      if (refresh != null) await _remote.logout(refresh);
      await _session.borrarSesion();
    } catch (e) {
      Bitacora.error('No se pudo borrar la sesión', e);
      // El usuario siempre debe poder salir, aunque falle el almacenamiento
    }
  }

  @override
  Future<String?> nombreUsuario() async {
    try {
      return await _session.leerNombre();
    } catch (e) {
      Bitacora.error('No se pudo leer el nombre', e);
      return null;
    }
  }

  @override
  Future<Result<Perfil>> miPerfil() async {
    final res = await _remote.miPerfil();
    return switch (res) {
      Ok(:final value) => Result.ok(value.toEntity()),
      Error(:final error) => Result.error(error),
    };
  }

  @override
  Future<Result<Perfil>> actualizarPerfil({required String nombre, required String apellidos}) async {
    final res = await _remote.actualizarPerfil(nombre: nombre, apellidos: apellidos);
    switch (res) {
      case Ok(:final value):
        try {
          await _session.guardarNombre(value.nombre);
        } catch (e) {
          Bitacora.error('No se pudo guardar el nombre', e);
        }
        return Result.ok(value.toEntity());
      case Error(:final error):
        return Result.error(error);
    }
  }

  @override
  Future<Result<String?>> cambiarPassword({required String actual, required String nueva}) =>
      _remote.cambiarPassword(actual: actual, nueva: nueva);
}
