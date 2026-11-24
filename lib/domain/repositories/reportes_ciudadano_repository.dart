import '../../core/result.dart';
import '../entities/estado_incidencia.dart';
import '../entities/incidencia_resumen.dart';
import '../entities/pagina.dart';
import '../entities/reporte_creado.dart';
import '../entities/reporte_nuevo.dart';

/// Reportes del ciudadano con sesión (HU-10).
abstract interface class ReportesCiudadanoRepository {
  /// `GET /incidencias/mias`. Si falla, devuelve una `FallaRed`.
  Future<Result<Pagina<IncidenciaResumen>>> misReportes({EstadoIncidencia? estado, int pagina = 0});

  /// `POST /incidencias` con la foto ya en Cloudinary. Un 422 llega como `EvidenciaInvalida` (RN-12).
  Future<Result<ReporteCreado>> crear(ReporteNuevo reporte, String fotoUrl);

  /// `POST /incidencias/{id}/confirmacion`: el ciudadano confirma la solución y la incidencia pasa
  /// de Resuelta a Cerrada (HU-13, RN-14). Devuelve el texto del servidor; 409 si ya no está Resuelta.
  Future<Result<String>> confirmarResolucion(int id);

  /// `POST /incidencias/{id}/reapertura`: el ciudadano reabre su reporte desde Resuelta (HU-23, RN-17).
  /// Devuelve el texto del servidor; 409 si ya van 2 reaperturas.
  Future<Result<String>> reabrir(int id, String justificacion);
}
