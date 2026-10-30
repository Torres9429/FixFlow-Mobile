import '../../domain/entities/tipo_incidencia.dart';
import '../../domain/repositories/incidence_type_repository.dart';

class FakeIncidenceTypeRepository implements IncidenceTypeRepository {
  @override
  Future<List<TipoIncidencia>> obtenerTipos() async => const [
        TipoIncidencia(id: 'bache', nombre: 'Bache'),
        TipoIncidencia(id: 'luminaria', nombre: 'Luminaria'),
        TipoIncidencia(id: 'fuga-agua', nombre: 'Fuga de agua'),
        TipoIncidencia(id: 'otro', nombre: 'Otro'),
      ];
}
