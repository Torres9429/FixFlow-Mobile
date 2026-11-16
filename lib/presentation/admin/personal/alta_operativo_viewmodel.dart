import 'package:flutter/foundation.dart';

import '../../../core/result.dart';
import '../../../domain/repositories/admin_repository.dart';
import '../../core/mensajes.dart';
import '../../core/notificador_seguro.dart';

class AltaOperativoViewModel extends ChangeNotifier with NotificadorSeguro {
  AltaOperativoViewModel(this._adminRepository);

  final AdminRepository _adminRepository;

  bool guardando = false;
  String? error;

  Future<bool> crear({
    required String nombre,
    required String apellidos,
    required String correo,
    required String passwordTemporal,
  }) async {
    guardando = true;
    error = null;
    notifyListeners();
    final resultado = await _adminRepository.crearOperativo(
      nombre: nombre.trim(),
      apellidos: apellidos.trim(),
      correo: correo.trim(),
      passwordTemporal: passwordTemporal,
    );
    guardando = false;
    if (resultado case Error(error: final falla)) {
      error = mensajePara(falla);
      notifyListeners();
      return false;
    }
    notifyListeners();
    return true;
  }
}
