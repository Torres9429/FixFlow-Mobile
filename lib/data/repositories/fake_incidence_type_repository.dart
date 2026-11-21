import '../../core/result.dart';
import '../../domain/entities/tipo_incidencia.dart';
import '../../domain/errors/falla_red.dart';
import '../../domain/repositories/incidence_type_repository.dart';
import 'fakes/datos_demo.dart';

/// Catálogo del modo mock: parte de `DatosDemo.tipos` y guarda los cambios en memoria mientras la app está abierta.
class FakeIncidenceTypeRepository implements IncidenceTypeRepository {
  // Copia propia: los cambios de esta instancia no tocan la lista de demo
  final _tipos = List.of(DatosDemo.tipos);

  static const _espera = Duration(milliseconds: 400);

  @override
  Future<Result<List<TipoIncidencia>>> obtenerTipos() async =>
      Result.ok(_tipos.where((t) => t.activo).toList(growable: false));

  @override
  Future<Result<List<TipoIncidencia>>> catalogo() async {
    await Future<void>.delayed(_espera);
    return Result.ok(List.unmodifiable(_tipos));
  }

  @override
  Future<Result<TipoIncidencia>> crear(DatosTipo datos) async {
    await Future<void>.delayed(_espera);
    final escrito = datos.codigo?.trim() ?? '';
    final String codigo;
    if (escrito.isNotEmpty) {
      if (_existe(escrito)) return const Result.error(Conflicto('Ya existe un tipo con ese código'));
      codigo = escrito;
    } else {
      // Como el back: si el código generado choca, recibe _2, _3…
      final base = codigoSugerido(datos.nombre);
      var candidato = base;
      for (var n = 2; _existe(candidato); n++) {
        candidato = '${base}_$n';
      }
      codigo = candidato;
    }
    final tipo = DatosDemo.tipo('${_tipos.length + 1}', datos.nombre.trim(), codigo, datos.orientacion, datos.prioridadBase, 0);
    _tipos.add(tipo);
    return Result.ok(tipo);
  }

  @override
  Future<Result<TipoIncidencia>> editar(String id, DatosTipo datos) async {
    await Future<void>.delayed(_espera);
    final (min, max) = DatosDemo.angulos(datos.orientacion);
    return _reemplazar(
      id,
      (t) => t.copyWith(
        nombre: datos.nombre.trim(),
        orientacion: datos.orientacion,
        prioridadBase: datos.prioridadBase,
        anguloMin: min,
        anguloMax: max,
      ),
    );
  }

  @override
  Future<Result<TipoIncidencia>> cambiarEstatus(String id, {required bool activo}) async {
    await Future<void>.delayed(_espera);
    return _reemplazar(id, (t) => t.copyWith(activo: activo));
  }

  bool _existe(String codigo) => _tipos.any((t) => t.codigo == codigo);

  Result<TipoIncidencia> _reemplazar(String id, TipoIncidencia Function(TipoIncidencia) cambio) {
    final i = _tipos.indexWhere((t) => t.id == id);
    if (i < 0) return const Result.error(NoEncontrado('El tipo de incidencia no existe'));
    _tipos[i] = cambio(_tipos[i]);
    return Result.ok(_tipos[i]);
  }
}
