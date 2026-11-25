import 'package:flutter/foundation.dart';

import '../../core/result.dart';
import '../../domain/repositories/avisos_repository.dart';
import '../core/notificador_seguro.dart';

/// Avisos sin leer del rol con sesión: el punto naranja de la pestaña o de la campana (design.md).
/// Vive encima del shell; se recarga al entrar, al volver a la app, al llegar un push y al leer avisos.
class ContadorAvisosViewModel extends ChangeNotifier with NotificadorSeguro {
  ContadorAvisosViewModel({required this._avisosRepository});

  final AvisosRepository _avisosRepository;

  int noLeidos = 0;

  bool get hayNoLeidos => noLeidos > 0;

  /// Si falla, se queda el último valor: el punto no es motivo para mostrar un error.
  Future<void> cargar() async {
    final res = await _avisosRepository.noLeidos();
    if (res case Ok(:final value) when value != noLeidos) {
      noLeidos = value;
      notifyListeners();
    }
  }
}
