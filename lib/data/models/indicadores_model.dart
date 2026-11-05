import '../../domain/entities/indicadores.dart';
import '../../domain/entities/prioridad.dart';
import 'incidencia_resumen_model.dart';

/// `result` de `GET /admin/indicadores`.
abstract final class IndicadoresModel {
  static Indicadores fromJson(Map<String, dynamic> r) {
    final porPrioridad = (r['porPrioridad'] as Map<String, dynamic>? ?? const {}).map(
      (clave, valor) => MapEntry(IncidenciaResumenModel.prioridadDesde(clave), (valor as num).toInt()),
    );
    return Indicadores(
      registradas: (r['registradas'] as num).toInt(),
      pendientes: (r['pendientes'] as num).toInt(),
      enAtencion: (r['enAtencion'] as num).toInt(),
      atendidas: (r['atendidas'] as num).toInt(),
      porPrioridad: {for (final p in Prioridad.values) p: porPrioridad[p] ?? 0},
      resolucionPromedioHoras: (r['resolucionPromedioHoras'] as num?)?.toDouble(),
      resolucionMaxHoras: (r['resolucionMaxHoras'] as num?)?.toDouble(),
    );
  }
}
