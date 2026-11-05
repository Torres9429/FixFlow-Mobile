import '../../domain/entities/estado_incidencia.dart';
import '../../domain/entities/incidencia_resumen.dart';
import '../../domain/entities/pagina.dart';
import '../../domain/entities/prioridad.dart';

/// Resumen de `/incidencias/mias`, `/operativo/incidencias` y `/admin/incidencias`.
abstract final class IncidenciaResumenModel {
  static IncidenciaResumen fromJson(Map<String, dynamic> j) => IncidenciaResumen(
    id: (j['id'] as num).toInt(),
    folio: j['folio'] as String,
    tipo: j['tipo'] as String,
    tipoCodigo: j['tipoCodigo'] as String,
    estado: _estado(j['estado'] as String),
    prioridad: _prioridad(j['prioridad'] as String),
    motivoPrioridad: j['motivoPrioridad'] as String? ?? '',
    latitud: (j['latitud'] as num).toDouble(),
    longitud: (j['longitud'] as num).toDouble(),
    fechaCreacion: DateTime.parse(j['fechaCreacion'] as String).toLocal(),
    ultimaActualizacion: DateTime.parse(j['ultimaActualizacion'] as String).toLocal(),
    operativo: j['operativo'] as String?,
    fotoUrl: j['fotoUrl'] as String?,
  );

  /// `result` = `{content: [...], page: {number, totalPages, ...}}`
  static Pagina<IncidenciaResumen> paginaFromJson(Map<String, dynamic> result) {
    final page = result['page'] as Map<String, dynamic>;
    return Pagina(
      contenido: (result['content'] as List<dynamic>)
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      numero: (page['number'] as num).toInt(),
      totalPaginas: (page['totalPages'] as num).toInt(),
    );
  }

  /// Valor de `?estado=` que entiende el back.
  static String codigoEstado(EstadoIncidencia e) => switch (e) {
    EstadoIncidencia.pendiente => 'PENDIENTE',
    EstadoIncidencia.asignada => 'ASIGNADA',
    EstadoIncidencia.enProceso => 'EN_PROCESO',
    EstadoIncidencia.resuelta => 'RESUELTA',
    EstadoIncidencia.reabierta => 'REABIERTA',
    EstadoIncidencia.cerrada => 'CERRADA',
  };

  static String codigoPrioridad(Prioridad p) => p.name.toUpperCase();

  static Prioridad prioridadDesde(String v) => _prioridad(v);

  static EstadoIncidencia _estado(String v) => switch (v) {
    'PENDIENTE' => EstadoIncidencia.pendiente,
    'ASIGNADA' => EstadoIncidencia.asignada,
    'EN_PROCESO' => EstadoIncidencia.enProceso,
    'RESUELTA' => EstadoIncidencia.resuelta,
    'REABIERTA' => EstadoIncidencia.reabierta,
    'CERRADA' => EstadoIncidencia.cerrada,
    _ => throw FormatException('Estado desconocido: $v'),
  };

  static Prioridad _prioridad(String v) => switch (v) {
    'ALTA' => Prioridad.alta,
    'MEDIA' => Prioridad.media,
    'BAJA' => Prioridad.baja,
    _ => throw FormatException('Prioridad desconocida: $v'),
  };
}
