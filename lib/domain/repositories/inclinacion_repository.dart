/// Acelerómetro del teléfono (RN-11).
abstract interface class InclinacionRepository {
  /// Inclinación actual en grados (+90 suelo, −90 cielo), o `null` si el sensor no respondió.
  Future<double?> leerInclinacion();

  /// Flujo continuo de lecturas de inclinación en grados (+90 suelo, −90 cielo) para la cámara en vivo (#23).
  Stream<double> observarInclinacion();
}
