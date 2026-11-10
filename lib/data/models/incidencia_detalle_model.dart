import '../../domain/entities/incidencia_detalle.dart';
import 'incidencia_resumen_model.dart';

/// Detalle de `GET /incidencias/{id}`. Trae los mismos campos que el resumen más los suyos.
abstract final class IncidenciaDetalleModel {
  static IncidenciaDetalle fromJson(Map<String, dynamic> j) =>
      IncidenciaDetalle(
        resumen: IncidenciaResumenModel.fromJson(j),
        descripcion: j['descripcion'] as String? ?? '',
        numReaperturas: (j['numReaperturas'] as num?)?.toInt() ?? 0,
        fechaResolucion: _fecha(j['fechaResolucion']),
        fotoReporteUrl: j['fotoReporteUrl'] as String?,
        fotoSolucionUrl: j['fotoSolucionUrl'] as String?,
        descripcionSolucion: j['descripcionSolucion'] as String?,
        motivoReapertura: j['motivoReapertura'] as String?,
        ciudadano: _nombre(j['ciudadano']),
        operativoAsignado: _nombre(j['operativoAsignado']),
        operativoAsignadoId: _id(j['operativoAsignado']),
      );

  static DateTime? _fecha(Object? v) =>
      v == null ? null : DateTime.parse(v as String).toLocal();

  /// `{id, nombre, apellidos}` → «Ana López»; `null` si el back no lo mandó.
  static String? _nombre(Object? v) {
    if (v is! Map<String, dynamic>) return null;
    return [v['nombre'], v['apellidos']].whereType<String>().join(' ');
  }

  static int? _id(Object? v) {
    if (v is! Map<String, dynamic>) return null;
    return (v['id'] as num?)?.toInt();
  }
}
