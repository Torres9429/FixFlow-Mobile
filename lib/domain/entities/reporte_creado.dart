import 'prioridad.dart';

/// Lo que regresa el back al crear el reporte; B5 lo muestra.
class ReporteCreado {
  const ReporteCreado({
    required this.id,
    required this.folio,
    required this.tipo,
    required this.prioridad,
    required this.fechaCreacion,
  });

  final int id;

  /// `FX-AAAA-NNNNNN`, lo genera el servidor (RN-08).
  final String folio;
  final String tipo;

  /// Prioridad base del tipo (RN-13).
  final Prioridad prioridad;
  final DateTime fechaCreacion;
}
