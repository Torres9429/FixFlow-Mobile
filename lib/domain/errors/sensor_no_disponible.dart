/// El teléfono no tiene acelerómetro o el sensor no responde (RN-11).
/// Llega por el `Stream` de `InclinacionRepository.observarInclinacion()`; nunca un `PlatformException`.
final class SensorNoDisponible implements Exception {
  const SensorNoDisponible();
}
