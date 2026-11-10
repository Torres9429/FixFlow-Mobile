import '../../core/result.dart';
import '../entities/estado_incidencia.dart';
import '../entities/incidencia_resumen.dart';
import '../entities/indicadores.dart';
import '../entities/operativo.dart';
import '../entities/pagina.dart';
import '../entities/prioridad.dart';

/// Consultas del administrador.
abstract interface class AdminRepository {
  /// `GET /admin/indicadores` (HU-19).
  Future<Result<Indicadores>> indicadores();

  /// `GET /admin/incidencias` con filtros (HU-17, HU-20).
  Future<Result<Pagina<IncidenciaResumen>>> incidencias({
    EstadoIncidencia? estado,
    Prioridad? prioridad,
    int pagina = 0,
    int tamano = 20,
  });

  /// `GET /operativos?activos=true` (HU-21).
  Future<Result<List<Operativo>>> operativosDisponibles();

  /// `POST /incidencias/{id}/asignacion` (HU-21).
  Future<Result<void>> asignarIncidencia(int incidenciaId, int operativoId);
}
