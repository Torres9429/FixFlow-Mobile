import 'package:flutter/foundation.dart';

/// Estado de la sesión que ya no se pudo renovar (refresh vencido, revocado o cuenta desactivada).
/// `ApiClient` llama a [avisar]; el router la recibe como `refreshListenable` y su `redirect` manda al login (RNF-09).
class SesionExpirada extends ChangeNotifier {
  bool _vencida = false;

  void avisar() {
    _vencida = true;
    notifyListeners();
  }

  /// `true` una sola vez por aviso, para que el redirect mande al login sin quedarse ahí al volver a entrar.
  bool consumirAviso() {
    if (!_vencida) return false;
    _vencida = false;
    return true;
  }
}
