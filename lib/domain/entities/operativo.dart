/// Personal operativo disponible para recibir incidencias (HU-21 y HU-24).
class Operativo {
  const Operativo({
    required this.id,
    required this.nombre,
    required this.apellidos,
    required this.activo,
    required this.cargaActual,
  });

  final int id;
  final String nombre;
  final String apellidos;
  final bool activo;
  final int cargaActual;

  String get nombreCompleto => '$nombre $apellidos';
}
