import '../../core/result.dart';
import '../entities/estado_incidencia.dart';
import '../entities/incidencia_resumen.dart';
import '../entities/pagina.dart';

/// Incidencias del operativo con sesión (HU-14). Nunca traen datos del ciudadano (RNF-04).
abstract interface class OperativoRepository {
  /// `GET /operativo/incidencias`, prioridad alta primero.
  Future<Result<Pagina<IncidenciaResumen>>> asignadas({EstadoIncidencia? estado, int pagina = 0});
}
