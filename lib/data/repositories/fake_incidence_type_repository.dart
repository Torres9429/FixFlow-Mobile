import '../../core/result.dart';
import '../../domain/entities/prioridad.dart';
import '../../domain/entities/tipo_incidencia.dart';
import '../../domain/errors/falla_red.dart';
import '../../domain/repositories/incidence_type_repository.dart';

/// Los 9 tipos de RN-07 con su orientación y prioridad base, más Grafiti inactivo (design.md, E10).
/// Guarda los cambios en memoria mientras la app está abierta.
class FakeIncidenceTypeRepository implements IncidenceTypeRepository {
  final _tipos = <TipoIncidencia>[
    _tipo('1', 'Bache', 'BACHE', OrientacionFoto.suelo, Prioridad.media, 142),
    _tipo('2', 'Luminaria apagada o dañada', 'LUMINARIA', OrientacionFoto.arriba, Prioridad.media, 87),
    _tipo('3', 'Fuga de agua', 'FUGA_AGUA', OrientacionFoto.sinRestriccion, Prioridad.alta, 64),
    _tipo('4', 'Coladera sin tapa u obstruida', 'COLADERA', OrientacionFoto.suelo, Prioridad.alta, 31),
    _tipo('5', 'Árbol o rama caída', 'ARBOL_CAIDO', OrientacionFoto.sinRestriccion, Prioridad.alta, 22),
    _tipo('6', 'Señalamiento vial dañado', 'SENALAMIENTO', OrientacionFoto.sinRestriccion, Prioridad.media, 18),
    _tipo('7', 'Banqueta dañada', 'BANQUETA', OrientacionFoto.suelo, Prioridad.baja, 40),
    _tipo('8', 'Basura acumulada', 'BASURA', OrientacionFoto.sinRestriccion, Prioridad.baja, 55),
    _tipo('9', 'Otro', 'OTRO', OrientacionFoto.sinRestriccion, Prioridad.baja, 12),
    _tipo('10', 'Grafiti', 'GRAFITI', OrientacionFoto.sinRestriccion, Prioridad.baja, 3, activo: false),
  ];

  static const _espera = Duration(milliseconds: 400);

  /// Los umbrales de RN-11 que manda el servidor: suelo ≥ +45°, arriba ≤ −20°.
  static (double, double) _angulos(OrientacionFoto o) => switch (o) {
    OrientacionFoto.suelo => (45, 90),
    OrientacionFoto.arriba => (-90, -20),
    OrientacionFoto.sinRestriccion => (-90, 90),
  };

  static TipoIncidencia _tipo(
    String id,
    String nombre,
    String codigo,
    OrientacionFoto orientacion,
    Prioridad prioridad,
    int incidencias, {
    bool activo = true,
  }) {
    final (min, max) = _angulos(orientacion);
    return TipoIncidencia(
      id: id,
      nombre: nombre,
      codigo: codigo,
      orientacion: orientacion,
      prioridadBase: prioridad,
      activo: activo,
      incidencias: incidencias,
      anguloMin: min,
      anguloMax: max,
    );
  }

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
    final tipo = _tipo('${_tipos.length + 1}', datos.nombre.trim(), codigo, datos.orientacion, datos.prioridadBase, 0);
    _tipos.add(tipo);
    return Result.ok(tipo);
  }

  @override
  Future<Result<TipoIncidencia>> editar(String id, DatosTipo datos) async {
    await Future<void>.delayed(_espera);
    final (min, max) = _angulos(datos.orientacion);
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
