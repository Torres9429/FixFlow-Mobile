/// Resultado retornado por la pantalla de cámara en vivo [CamaraOrientacionScreen] (B3 / #23).
class ResultadoCaptura {
  const ResultadoCaptura({
    required this.rutaFoto,
    required this.inclinacion,
    required this.capturadaEn,
  });

  /// Ruta absoluta del archivo de imagen capturado con la cámara.
  final String rutaFoto;

  /// Inclinación en grados medida por el acelerómetro en el instante exacto del disparo (RN-11).
  final double inclinacion;

  /// Marca de tiempo de la captura.
  final DateTime capturadaEn;
}

