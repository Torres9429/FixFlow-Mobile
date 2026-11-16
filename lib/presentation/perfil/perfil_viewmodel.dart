import 'package:flutter/foundation.dart';

import '../../core/result.dart';
import '../../domain/entities/perfil.dart';
import '../../domain/repositories/auth_repository.dart';
import '../core/estado_consulta.dart';
import '../core/mensajes.dart';
import '../core/notificador_seguro.dart';

class PerfilViewModel extends ChangeNotifier with NotificadorSeguro {
  PerfilViewModel({required this._authRepository});

  final AuthRepository _authRepository;

  EstadoConsulta<Perfil> estado = const Cargando();
  bool cerrandoSesion = false;

  Future<void> cargar() async {
    if (estado is! Listo) {
      estado = const Cargando();
      notifyListeners();
    }

    final res = await _authRepository.miPerfil();
    estado = switch (res) {
      Ok(:final value) => Listo(value),
      Error(:final error) => ConError(mensajePara(error)),
    };
    notifyListeners();
  }

  void actualizar(Perfil perfil) {
    estado = Listo(perfil);
    notifyListeners();
  }

  Future<void> cerrarSesion() async {
    cerrandoSesion = true;
    notifyListeners();
    await _authRepository.cerrarSesion();
    cerrandoSesion = false;
    notifyListeners();
  }
}
