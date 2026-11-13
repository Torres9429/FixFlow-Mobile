import 'package:flutter/foundation.dart';

import '../../../core/result.dart';
import '../../../domain/entities/perfil.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../core/mensajes.dart';
import '../../core/notificador_seguro.dart';

class EditarDatosViewModel extends ChangeNotifier with NotificadorSeguro {
  EditarDatosViewModel({required this._authRepository, required this.perfil});

  final AuthRepository _authRepository;
  final Perfil perfil;

  bool guardando = false;
  String? error;
  Perfil? guardado;

  Future<void> guardar({required String nombre, required String apellidos}) async {
    guardando = true;
    error = null;
    notifyListeners();

    final res = await _authRepository.actualizarPerfil(nombre: nombre.trim(), apellidos: apellidos.trim());
    switch (res) {
      case Ok(:final value):
        guardado = value;
      case Error(error: final falla):
        error = mensajePara(falla);
    }
    guardando = false;
    notifyListeners();
  }
}
