import 'prioridad.dart';

/// Cifras del panel del admin (HU-19, E1).
class Indicadores {
  const Indicadores({
    required this.registradas,
    required this.pendientes,
    required this.enAtencion,
    required this.atendidas,
    required this.porPrioridad,
    this.resolucionPromedioHoras,
    this.resolucionMaxHoras,
  });

  final int registradas;
  final int pendientes;
  final int enAtencion;
  final int atendidas;
  final Map<Prioridad, int> porPrioridad;

  /// `null` mientras no haya ninguna incidencia resuelta.
  final double? resolucionPromedioHoras;
  final double? resolucionMaxHoras;
}
