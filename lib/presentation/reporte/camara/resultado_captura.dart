/// Resultado retornado por la pantalla de cámara en vivo [CamaraOrientacionScreen] (B3 / #23).
class ResultadoCaptura {
  const ResultadoCaptura({
    required this.rutaFoto,
    required this.inclinacion,
    required this.capturadaEn,
    this.sinSensor = false,
  });

  /// Ruta absoluta del archivo de imagen capturado con la cámara.
  final String rutaFoto;

  /// Inclinación en grados: promedio de ~0.5 s antes del disparo (RN-11). `null` si el teléfono no tiene sensor.
  final double? inclinacion;

  /// Marca de tiempo de la captura.
  final DateTime capturadaEn;

  /// La cámara terminó sin sensor (de inicio o porque el sensor no respondió): B2 lo manda como `sinSensor`.
  final bool sinSensor;
}

