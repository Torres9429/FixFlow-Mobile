import '../../domain/entities/reporte_creado.dart';
import 'incidencia_resumen_model.dart';

/// `result` de `POST /incidencias`: el detalle de la incidencia recién creada.
abstract final class ReporteCreadoModel {
  static ReporteCreado fromJson(Map<String, dynamic> r) => ReporteCreado(
    id: (r['id'] as num).toInt(),
    folio: r['folio'] as String,
    tipo: r['tipo'] as String,
    prioridad: IncidenciaResumenModel.prioridadDesde(r['prioridad'] as String),
    fechaCreacion: DateTime.parse(r['fechaCreacion'] as String).toLocal(),
  );
}
