import 'tipo_incidencia.dart';

/// Lo que el ciudadano capturó en B2 y revisa en B4 antes de enviar (HU-03 a HU-08).
class ReporteNuevo {
  const ReporteNuevo({
    required this.tipo,
    required this.descripcion,
    required this.latitud,
    required this.longitud,
    required this.rutaFoto,
    required this.capturadaEn,
    this.inclinacion,
  });

  final TipoIncidencia tipo;
  final String descripcion;

  /// GPS del momento de la captura; nunca se escribe a mano (RN-10).
  final double latitud;
  final double longitud;

  /// Grados: +90 es el suelo, 0 el horizonte y −90 el cielo. `null` si el acelerómetro no respondió.
  final double? inclinacion;

  /// Archivo local de la foto tomada en vivo (RN-09).
  final String rutaFoto;
  final DateTime capturadaEn;
}
