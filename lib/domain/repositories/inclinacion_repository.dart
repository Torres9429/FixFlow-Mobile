/// Acelerómetro del teléfono (RN-11).
abstract interface class InclinacionRepository {
  /// Si el teléfono tiene acelerómetro. Sin él se reporta sin validar la inclinación (RN-11, B3e).
  Future<bool> sensorDisponible();

  /// Inclinación actual en grados (+90 suelo, −90 cielo), o `null` si el sensor no respondió.
  Future<double?> leerInclinacion();

  /// Lecturas continuas en grados (+90 suelo, −90 cielo) para la cámara en vivo.
  /// Si el sensor falta o falla, el stream emite un `SensorNoDisponible`.
  Stream<double> observarInclinacion();
}
