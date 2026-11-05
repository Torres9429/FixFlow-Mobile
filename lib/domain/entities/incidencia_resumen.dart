import 'estado_incidencia.dart';
import 'prioridad.dart';

/// Lo que muestran las tarjetas de B1, D1, E1 y E2 y los puntos del mapa.
class IncidenciaResumen {
  const IncidenciaResumen({
    required this.id,
    required this.folio,
    required this.tipo,
    required this.tipoCodigo,
    required this.estado,
    required this.prioridad,
    required this.motivoPrioridad,
    required this.latitud,
    required this.longitud,
    required this.fechaCreacion,
    required this.ultimaActualizacion,
    this.operativo,
    this.fotoUrl,
  });

  final int id;
  final String folio;
  final String tipo;
  final String tipoCodigo;
  final EstadoIncidencia estado;
  final Prioridad prioridad;
  final String motivoPrioridad;
  final double latitud;
  final double longitud;
  final DateTime fechaCreacion;
  final DateTime ultimaActualizacion;

  /// Nombre completo del responsable; `null` mientras está Pendiente.
  final String? operativo;

  /// Miniatura de la foto del reporte.
  final String? fotoUrl;
}
