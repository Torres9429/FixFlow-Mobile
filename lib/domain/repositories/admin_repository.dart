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

  /// `GET /operativos?activos=false` (HU-24).
  Future<Result<List<Operativo>>> listarOperativos();

  /// `POST /admin/operativos` con rol operativo y contraseña temporal (HU-24).
  Future<Result<void>> crearOperativo({
    required String nombre,
    required String apellidos,
    required String correo,
    required String passwordTemporal,
  });

  /// `PATCH /admin/operativos/{id}/estatus` (HU-24).
  Future<Result<void>> cambiarEstatusOperativo(int id, {required bool activo});

  /// `POST /incidencias/{id}/asignacion` (HU-21).
  Future<Result<void>> asignarIncidencia(int incidenciaId, int operativoId);
}
