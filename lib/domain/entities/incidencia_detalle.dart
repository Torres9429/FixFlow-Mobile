import 'incidencia_resumen.dart';

/// Lo que muestran C2, D2 y E4 (HU-11). Quién la ve cambia qué llega: el operativo recibe [ciudadano] en `null` (RNF-04).
class IncidenciaDetalle {
  const IncidenciaDetalle({
    required this.resumen,
    required this.descripcion,
    required this.numReaperturas,
    this.fechaResolucion,
    this.fotoReporteUrl,
    this.fotoSolucionUrl,
    this.descripcionSolucion,
    this.motivoReapertura,
    this.ciudadano,
    this.operativoAsignado,
  });

  /// Folio, tipo, estado, prioridad, ubicación y fechas: lo mismo que la tarjeta.
  final IncidenciaResumen resumen;

  final String descripcion;
  final int numReaperturas;
  final DateTime? fechaResolucion;
  final String? fotoReporteUrl;
  final String? fotoSolucionUrl;
  final String? descripcionSolucion;
  final String? motivoReapertura;

  /// Nombre completo de quien reportó; `null` para el operativo.
  final String? ciudadano;

  /// Nombre completo del responsable; `null` mientras está Pendiente.
  final String? operativoAsignado;
}
