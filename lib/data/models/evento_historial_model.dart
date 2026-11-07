import '../../domain/entities/evento_historial.dart';
import 'incidencia_resumen_model.dart';

/// Un registro de `GET /incidencias/{id}/historial`.
abstract final class EventoHistorialModel {
  static EventoHistorial fromJson(Map<String, dynamic> j) => EventoHistorial(
    id: (j['id'] as num).toInt(),
    accion: _accion(j['accion'] as String),
    realizadoPor: j['realizadoPor'] as String? ?? 'Sistema',
    fecha: DateTime.parse(j['fechaCreacion'] as String).toLocal(),
    estadoNuevo: switch (j['estadoNuevo']) {
      final String v => IncidenciaResumenModel.estadoDesde(v),
      _ => null,
    },
    prioridadNueva: switch (j['prioridadNueva']) {
      final String v => IncidenciaResumenModel.prioridadDesde(v),
      _ => null,
    },
    operativo: j['operativo'] as String?,
    comentario: j['comentario'] as String?,
    fotoUrl: j['fotoUrl'] as String?,
  );

  static List<EventoHistorial> listaFromJson(List<dynamic> result) =>
      result.map((e) => fromJson(e as Map<String, dynamic>)).toList(growable: false);

  static AccionHistorial _accion(String v) => switch (v) {
    'CREADA' => AccionHistorial.creada,
    'ASIGNACION' => AccionHistorial.asignacion,
    'REASIGNACION' => AccionHistorial.reasignacion,
    'CAMBIO_ESTADO' => AccionHistorial.cambioEstado,
    'SOLUCION' => AccionHistorial.solucion,
    'REAPERTURA' => AccionHistorial.reapertura,
    'CAMBIO_PRIORIDAD' => AccionHistorial.cambioPrioridad,
    _ => throw FormatException('Acción de historial desconocida: $v'),
  };
}
