import '../../../core/result.dart';
import '../../../domain/entities/estado_incidencia.dart';
import '../../../domain/entities/incidencia_resumen.dart';
import '../../../domain/entities/pagina.dart';
import '../../../domain/entities/prioridad.dart';
import '../../../domain/entities/reporte_creado.dart';
import '../../../domain/entities/reporte_nuevo.dart';
import '../../../domain/errors/falla_red.dart';
import '../../../domain/repositories/reportes_ciudadano_repository.dart';
import 'datos_demo.dart';

/// Mis reportes en el modo mock: los 4 de Ana de design.md §9. Los que se envían se agregan al inicio.
class FakeReportesCiudadanoRepository implements ReportesCiudadanoRepository {
  FakeReportesCiudadanoRepository({List<IncidenciaResumen>? reportes})
    : _reportes = List.of(reportes ?? DatosDemo.reportesAna);

  final List<IncidenciaResumen> _reportes;
  int _siguienteId = 143;

  @override
  Future<Result<Pagina<IncidenciaResumen>>> misReportes({EstadoIncidencia? estado, int pagina = 0}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final filtrados = _reportes.where((r) => estado == null || r.estado == estado).toList();
    return Result.ok(Pagina(contenido: filtrados, numero: 0, totalPaginas: 1));
  }

  @override
  Future<Result<ReporteCreado>> crear(ReporteNuevo reporte, String fotoUrl) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final id = _siguienteId++;
    final ahora = DateTime.now();
    final folio = 'FX-${ahora.year}-${id.toString().padLeft(6, '0')}';

    _reportes.insert(
      0,
      IncidenciaResumen(
        id: id,
        folio: folio,
        tipo: reporte.tipo.nombre,
        tipoCodigo: reporte.tipo.codigo,
        estado: EstadoIncidencia.pendiente,
        // En el back la prioridad sale del tipo (RN-13); aquí basta un valor
        prioridad: Prioridad.media,
        motivoPrioridad: 'Tipo de incidencia: ${reporte.tipo.nombre}',
        latitud: reporte.latitud,
        longitud: reporte.longitud,
        fechaCreacion: ahora,
        ultimaActualizacion: ahora,
        fotoUrl: fotoUrl,
      ),
    );
    return Result.ok(
      ReporteCreado(id: id, folio: folio, tipo: reporte.tipo.nombre, prioridad: Prioridad.media, fechaCreacion: ahora),
    );
  }

  /// En el modo mock solo responde como el back; el detalle de demo sigue en Resuelta al recargar.
  @override
  Future<Result<String>> confirmarResolucion(int id) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return const Result.ok('Solución confirmada; la incidencia quedó cerrada');
  }

  /// Reabre como el back y actualiza la lista para que B1 muestre el nuevo estado al recargar.
  /// El fake no lleva la cuenta de las 2 reaperturas (la pantalla de detalle lo impide) y el detalle
  /// de demo conserva su propio estado.
  @override
  Future<Result<String>> reabrir(int id, String justificacion) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final idx = _reportes.indexWhere((r) => r.id == id);
    if (idx == -1) return Result.error(const NoEncontrado('La incidencia no existe'));

    final actual = _reportes[idx];
    if (actual.estado != EstadoIncidencia.resuelta) {
      return Result.error(const Conflicto('La incidencia ya no está resuelta'));
    }

    _reportes[idx] = IncidenciaResumen(
      id: actual.id,
      folio: actual.folio,
      tipo: actual.tipo,
      tipoCodigo: actual.tipoCodigo,
      estado: EstadoIncidencia.reabierta,
      prioridad: Prioridad.alta,
      motivoPrioridad: 'Reabierta por el ciudadano',
      latitud: actual.latitud,
      longitud: actual.longitud,
      fechaCreacion: actual.fechaCreacion,
      ultimaActualizacion: DateTime.now(),
      operativo: actual.operativo,
      fotoUrl: actual.fotoUrl,
    );
    return const Result.ok('Reporte reabierto; el personal operativo verá tu motivo');
  }
}
