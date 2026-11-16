import '../../core/result.dart';
import '../entities/tipo_incidencia.dart';

abstract interface class IncidenceTypeRepository {
  /// `GET /tipos-incidencia`: solo los activos. Si falla, devuelve una `FallaRed`.
  Future<Result<List<TipoIncidencia>>> obtenerTipos();

  /// `GET /admin/tipos-incidencia`: activos e inactivos, con cuántas incidencias usan cada uno (E10).
  Future<Result<List<TipoIncidencia>>> catalogo();

  /// `POST /admin/tipos-incidencia` (E11). Un código repetido devuelve `Conflicto`.
  Future<Result<TipoIncidencia>> crear(DatosTipo datos);

  /// `PUT /admin/tipos-incidencia/{id}` (E12). El código no cambia.
  Future<Result<TipoIncidencia>> editar(String id, DatosTipo datos);

  /// `PATCH /admin/tipos-incidencia/{id}/estatus` (E12a).
  Future<Result<TipoIncidencia>> cambiarEstatus(String id, {required bool activo});
}
