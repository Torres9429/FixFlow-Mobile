import '../entities/coordenada.dart';

/// GPS del teléfono.
abstract interface class UbicacionRepository {
  /// Posición actual, o `null` si no hay permiso o el GPS está apagado.
  Future<Coordenada?> posicionActual();
}
