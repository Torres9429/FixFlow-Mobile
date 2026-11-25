import '../../domain/entities/accion_aviso.dart';
import '../../domain/entities/aviso.dart';
import '../../domain/entities/pagina.dart';

/// Aviso de `GET /notificaciones` (NotificacionResponseDTO del back).
abstract final class AvisoModel {
  static Aviso fromJson(Map<String, dynamic> j) => Aviso(
    id: (j['id'] as num).toInt(),
    titulo: j['titulo'] as String,
    mensaje: j['mensaje'] as String,
    leida: j['leida'] as bool? ?? false,
    fecha: DateTime.parse(j['fechaCreacion'] as String).toLocal(),
    incidenciaId: (j['incidenciaId'] as num).toInt(),
    folio: j['folio'] as String? ?? '',
    accion: AccionAviso.desde(j['accion'] as String?),
  );

  /// `result` = `{content: [...], page: {number, totalPages, ...}}`
  static Pagina<Aviso> paginaFromJson(Map<String, dynamic> result) {
    final page = result['page'] as Map<String, dynamic>;
    return Pagina(
      contenido: (result['content'] as List<dynamic>)
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      numero: (page['number'] as num).toInt(),
      totalPaginas: (page['totalPages'] as num).toInt(),
    );
  }
}
