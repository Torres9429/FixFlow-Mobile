import 'package:flutter/foundation.dart';

import '../../../core/result.dart';
import '../../../domain/entities/rol.dart';
import '../../../domain/entities/usuario.dart';
import '../../../domain/errors/auth_failure.dart';
import '../../../domain/repositories/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({required this._authRepository});

  final AuthRepository _authRepository;

  bool cargando = false;
  String? error;
  Usuario? usuario;

  Future<void> iniciarSesion(String correo, String password) async {
    cargando = true;
    error = null;
    notifyListeners();

    try {
      final res = await _authRepository.iniciarSesion(correo.trim(), password);
      switch (res) {
        case Ok(:final value) when value.rol == Rol.desconocido:
          await _authRepository.cerrarSesion();
          error = 'Tu cuenta no tiene un rol válido';
        case Ok(:final value):
          usuario = value;
        case Error(error: final falla):
          error = _mensaje(falla);
      }
    } catch (e) {
      debugPrint('[FixFlow] Error inesperado al iniciar sesión: $e');
      // Red de seguridad: el botón nunca debe quedarse cargando
      error = _mensaje(const ErrorDesconocido());
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  String _mensaje(Object falla) => switch (falla) {
        CredencialesInvalidas() => 'Correo o contraseña no válidos',
        SinConexion() => 'Sin conexión. Intenta de nuevo.',
        _ => 'Ocurrió un error. Intenta de nuevo.',
      };
}
