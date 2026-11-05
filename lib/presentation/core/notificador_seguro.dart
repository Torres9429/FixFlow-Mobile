import 'package:flutter/foundation.dart';

/// Evita avisar a una pantalla que ya se cerró: si una petición termina después de `dispose()`,
/// `notifyListeners()` no hace nada en lugar de lanzar «used after being disposed».
mixin NotificadorSeguro on ChangeNotifier {
  bool _liberado = false;

  @override
  void notifyListeners() {
    if (!_liberado) super.notifyListeners();
  }

  @override
  void dispose() {
    _liberado = true;
    super.dispose();
  }
}
