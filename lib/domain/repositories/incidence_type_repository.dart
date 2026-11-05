import '../../core/result.dart';
import '../entities/tipo_incidencia.dart';

abstract interface class IncidenceTypeRepository {
  /// `GET /tipos-incidencia`: solo los activos. Si falla, devuelve una `FallaRed`.
  Future<Result<List<TipoIncidencia>>> obtenerTipos();
}
