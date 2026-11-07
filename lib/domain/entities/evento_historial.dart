import 'estado_incidencia.dart';
import 'prioridad.dart';

/// Acciones que deja el back en el historial (RN-15).
enum AccionHistorial { creada, asignacion, reasignacion, cambioEstado, solucion, reapertura, cambioPrioridad }

/// Un evento de la línea de tiempo del detalle (HU-22): qué pasó, quién y cuándo.
class EventoHistorial {
  const EventoHistorial({
    required this.id,
    required this.accion,
    required this.realizadoPor,
    required this.fecha,
    this.estadoNuevo,
    this.prioridadNueva,
    this.operativo,
    this.comentario,
    this.fotoUrl,
  });

  final int id;
  final AccionHistorial accion;

  /// Nombre completo, «Sistema» o, para el operativo, «Ciudadano».
  final String realizadoPor;
  final DateTime fecha;
  final EstadoIncidencia? estadoNuevo;
  final Prioridad? prioridadNueva;

  /// Responsable nuevo en una asignación o reasignación.
  final String? operativo;
  final String? comentario;
  final String? fotoUrl;
}
