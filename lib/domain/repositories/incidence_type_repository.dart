import '../entities/tipo_incidencia.dart';

abstract interface class IncidenceTypeRepository {
  Future<List<TipoIncidencia>> obtenerTipos();
}
