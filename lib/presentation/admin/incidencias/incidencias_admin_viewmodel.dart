import 'package:flutter/foundation.dart';

import '../../../core/result.dart';
import '../../../domain/entities/estado_incidencia.dart';
import '../../../domain/entities/incidencia_resumen.dart';
import '../../../domain/entities/prioridad.dart';
import '../../../domain/entities/tipo_incidencia.dart';
import '../../../domain/repositories/admin_repository.dart';
import '../../../domain/repositories/incidence_type_repository.dart';
import '../../core/estado_consulta.dart';
import '../../core/mensajes.dart';
import '../../core/notificador_seguro.dart';

/// E2 Incidencias del municipio (HU-17): lista, búsqueda y filtros de estado, tipo y prioridad.
///
/// Solo la prioridad viaja al back (es el único filtro que el contrato ya expone hoy).
/// La búsqueda y el tipo se aplican sobre lo cargado para no tocar `AdminRepository`,
/// que es compartido con las demás HUs de administración.
class IncidenciasAdminViewModel extends ChangeNotifier with NotificadorSeguro {
  IncidenciasAdminViewModel({required this.adminRepository, required this.tiposRepository});

  final AdminRepository adminRepository;
  final IncidenceTypeRepository tiposRepository;

  EstadoConsulta<List<IncidenciaResumen>> estado = const Cargando();

  /// Texto del buscador: folio o tipo.
  String busqueda = '';

  /// Chip de estado.
  EstadoIncidencia? filtro;

  /// Prioridad: el único filtro que se pide al back.
  Prioridad? prioridad;

  /// Id del tipo elegido en el desplegable; vacío = Todos.
  String tipoId = '';

  /// Catálogo activo para el desplegable de tipo; vacío si todavía no llegó.
  List<TipoIncidencia> tipos = const [];

  bool cargandoMas = false;

  int _pagina = 0;
  bool _esUltima = true;

  /// Cada recarga deja atrás a la anterior: si llega tarde, se descarta.
  int _generacion = 0;

  List<IncidenciaResumen> get _cargados => switch (estado) {
    Listo(:final datos) => datos,
    _ => const [],
  };

  /// Todo lo que se cargó (todas las páginas), sin aplicar los filtros de la pantalla.
  List<IncidenciaResumen> get incidencias => _cargados;

  /// Código del tipo elegido («BACHE»), para comparar con `IncidenciaResumen.tipoCodigo`.
  String get _codigoTipo {
    if (tipoId.isEmpty) return '';
    for (final tipo in tipos) {
      if (tipo.id == tipoId) return tipo.codigo.toUpperCase();
    }
    return tipoId.toUpperCase();
  }

  /// Conjunto cargado con texto y tipo aplicados, pero sin el chip de estado.
  List<IncidenciaResumen> get _sinChip {
    final consulta = busqueda.trim().toLowerCase();
    final codigo = _codigoTipo;
    return _cargados.where((i) {
      if (codigo.isNotEmpty && i.tipoCodigo.toUpperCase() != codigo) return false;
      if (consulta.isNotEmpty &&
          !i.folio.toLowerCase().contains(consulta) &&
          !i.tipo.toLowerCase().contains(consulta)) {
        return false;
      }
      return true;
    }).toList(growable: false);
  }

  /// Lo que se pinta: estado, texto y tipo aplicados sobre el conjunto cargado.
  List<IncidenciaResumen> get visibles => filtro == null
      ? _sinChip
      : _sinChip.where((i) => i.estado == filtro).toList(growable: false);

  /// Conteo de un chip, sobre lo cargado y respetando texto y tipo.
  int contar(EstadoIncidencia? e) {
    final base = _sinChip;
    return e == null ? base.length : base.where((i) => i.estado == e).length;
  }

  Future<void> iniciar() async {
    await (cargar(), cargarTipos()).wait;
  }

  /// Si el catálogo no llega, el desplegable se queda solo con «Todos».
  Future<void> cargarTipos() async {
    if (await tiposRepository.obtenerTipos() case Ok(value: final lista)) {
      tipos = lista;
      notifyListeners();
    }
  }

  /// Al recargar se deja la lista actual a la vista hasta que llega la nueva.
  Future<void> cargar() => _cargar(conEsqueleto: false);

  /// La búsqueda solo estrecha lo ya cargado; no vuelve a pedir nada al back.
  void buscar(String valor) {
    if (valor == busqueda) return;
    busqueda = valor;
    notifyListeners();
  }

  /// El tipo solo estrecha lo ya cargado.
  void cambiarTipo(String id) {
    if (id == tipoId) return;
    tipoId = id;
    notifyListeners();
  }

  /// Otra prioridad son otros datos: se muestra el esqueleto.
  Future<void> cambiarPrioridad(Prioridad? nueva) async {
    if (nueva == prioridad) return;
    prioridad = nueva;
    await _cargar(conEsqueleto: true);
  }

  /// El chip solo estrecha lo ya cargado; no vuelve a pedir nada al back.
  void cambiarFiltro(EstadoIncidencia? nuevo) {
    if (nuevo == filtro) return;
    filtro = nuevo;
    notifyListeners();
  }

  Future<void> _cargar({required bool conEsqueleto}) async {
    final generacion = ++_generacion;
    if (conEsqueleto || estado is! Listo) {
      estado = const Cargando();
      notifyListeners();
    }

    final res = await adminRepository.incidencias(prioridad: prioridad);
    if (generacion != _generacion) return;

    switch (res) {
      case Ok(:final value):
        estado = Listo(value.contenido);
        _pagina = value.numero;
        _esUltima = value.esUltima;
      case Error(error: final falla):
        estado = ConError(mensajePara(falla));
    }
    notifyListeners();
  }

  /// Siguiente página al llegar al final de la lista.
  Future<void> cargarMas() async {
    if (_esUltima || estado is! Listo || cargandoMas) return;
    cargandoMas = true;
    notifyListeners();
    final generacion = _generacion;

    final res = await adminRepository.incidencias(
      prioridad: prioridad,
      pagina: _pagina + 1,
    );
    if (generacion != _generacion) {
      cargandoMas = false;
      notifyListeners();
      return;
    }
    if (res case Ok(:final value)) {
      estado = Listo([..._cargados, ...value.contenido]);
      _pagina = value.numero;
      _esUltima = value.esUltima;
    }
    cargandoMas = false;
    notifyListeners();
  }
}
