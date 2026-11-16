import 'package:flutter/foundation.dart';

import '../../../core/result.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/validators/campos_validators.dart';
import '../../core/mensajes.dart';
import '../../core/notificador_seguro.dart';

class CambiarPasswordViewModel extends ChangeNotifier with NotificadorSeguro {
  CambiarPasswordViewModel({required this._authRepository});

  static const mensajeExito = 'Tu contraseña se cambió';

  final AuthRepository _authRepository;

  bool guardando = false;
  String? error;
  String? exito;

  /// Lo que se lleva escrito, para marcar los requisitos mientras se escribe.
  String actual = '';
  String nueva = '';

  RequisitosPassword get requisitos => requisitosPassword(nueva, actual);

  void cambiarActual(String valor) {
    actual = valor;
    notifyListeners();
  }

  void cambiarNueva(String valor) {
    nueva = valor;
    notifyListeners();
  }

  Future<void> cambiar({required String actual, required String nueva}) async {
    guardando = true;
    error = null;
    notifyListeners();

    final res = await _authRepository.cambiarPassword(actual: actual, nueva: nueva);
    switch (res) {
      case Ok(:final value):
        exito = (value == null || value.trim().isEmpty) ? mensajeExito : value;
      case Error(error: final falla):
        error = mensajePara(falla);
    }
    guardando = false;
    notifyListeners();
  }
}
