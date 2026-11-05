import '../../core/result.dart';
import '../../domain/entities/tipo_incidencia.dart';
import '../../domain/repositories/incidence_type_repository.dart';

/// Los 9 tipos del catálogo de design.md §2, con su orientación.
class FakeIncidenceTypeRepository implements IncidenceTypeRepository {
  @override
  Future<Result<List<TipoIncidencia>>> obtenerTipos() async => const Result.ok([
    TipoIncidencia(id: '1', nombre: 'Bache', codigo: 'BACHE', orientacion: OrientacionFoto.suelo),
    TipoIncidencia(
      id: '2',
      nombre: 'Luminaria apagada o dañada',
      codigo: 'LUMINARIA',
      orientacion: OrientacionFoto.arriba,
    ),
    TipoIncidencia(id: '3', nombre: 'Fuga de agua', codigo: 'FUGA_AGUA'),
    TipoIncidencia(
      id: '4',
      nombre: 'Coladera sin tapa u obstruida',
      codigo: 'COLADERA',
      orientacion: OrientacionFoto.suelo,
    ),
    TipoIncidencia(id: '5', nombre: 'Árbol o rama caída', codigo: 'ARBOL_CAIDO'),
    TipoIncidencia(id: '6', nombre: 'Señalamiento vial dañado', codigo: 'SENALAMIENTO'),
    TipoIncidencia(id: '7', nombre: 'Banqueta dañada', codigo: 'BANQUETA', orientacion: OrientacionFoto.suelo),
    TipoIncidencia(id: '8', nombre: 'Basura acumulada', codigo: 'BASURA'),
    TipoIncidencia(id: '9', nombre: 'Otro', codigo: 'OTRO'),
  ]);
}
