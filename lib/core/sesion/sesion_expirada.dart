import 'package:flutter/foundation.dart';

/// Avisa que la sesión ya no se pudo renovar (refresh vencido, revocado o cuenta desactivada).
/// `ApiClient` llama a [avisar]; la app escucha y manda al login (RNF-09).
class SesionExpirada extends ChangeNotifier {
  void avisar() => notifyListeners();
}
