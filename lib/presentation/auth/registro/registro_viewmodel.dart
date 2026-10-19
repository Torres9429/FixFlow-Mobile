import 'package:flutter/foundation.dart';

import '../../../core/result.dart';
import '../../../domain/errors/auth_failure.dart';
import '../../../domain/repositories/auth_repository.dart';

class RegistroViewModel extends ChangeNotifier {
  RegistroViewModel({required this._authRepository});

  final AuthRepository _authRepository;

  bool cargando = false;
  String? error;
  bool registroExitoso = false;

  Future<void> registrar({
    required String nombre,
    required String apellidos,
    required String correo,
    required String password,
  }) async {
    cargando = true;
    error = null;
    notifyListeners();

    try {
      final res = await _authRepository.registrar(
        nombre: nombre.trim(),
        apellidos: apellidos.trim(),
        correo: correo.trim(),
        password: password,
      );
      switch (res) {
        case Ok():
          registroExitoso = true;
        case Error(error: final falla):
          error = _mensaje(falla);
      }
    } catch (e) {
      debugPrint('[FixFlow] Error inesperado al registrar: $e');
      error = _mensaje(const ErrorDesconocido());
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  String _mensaje(Object falla) => switch (falla) {
        CorreoDuplicado() => 'Ya existe una cuenta con ese correo',
        SinConexion() => 'Sin conexión. Intenta de nuevo.',
        _ => 'Ocurrió un error. Intenta de nuevo.',
      };
}
