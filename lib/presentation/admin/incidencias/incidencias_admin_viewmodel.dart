import 'dart:async';

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
/// Todos los filtros viajan al back (`estado`, `tipoId`, `prioridad`, `q`): cada cambio
/// vuelve a pedir la página 0 y el scroll infinito sigue pidiendo con los mismos filtros.
class IncidenciasAdminViewModel extends ChangeNotifier with NotificadorSeguro {
  IncidenciasAdminViewModel({required this._adminRepository, required this._tiposRepository});

  final AdminRepository _adminRepository;
  final IncidenceTypeRepository _tiposRepository;

  EstadoConsulta<List<IncidenciaResumen>> estado = const Cargando();

  /// Texto del buscador: viaja como `q` (el back busca por folio o tipo).
  String busqueda = '';

  /// Chip de estado.
  EstadoIncidencia? filtro;

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

  /// Espera a que el usuario deje de escribir antes de pedir la búsqueda al back.
  Timer? _busquedaTimer;

  List<IncidenciaResumen> get _cargados => switch (estado) {
    Listo(:final datos) => datos,
    _ => const [],
  };

  /// Lo que devolvió el back, ya filtrado en el servidor.
  List<IncidenciaResumen> get incidencias => _cargados;

  /// Cierto cuando llegó la última página: el total y el pie solo se muestran entonces.
  bool get esUltima => _esUltima;

  Future<void> iniciar() async {
    await (cargar(), cargarTipos()).wait;
  }

  /// Si el catálogo no llega, el desplegable se queda solo con «Todos».
  Future<void> cargarTipos() async {
    if (await _tiposRepository.obtenerTipos() case Ok(value: final lista)) {
      tipos = lista;
      notifyListeners();
    }
  }

  /// Al recargar se deja la lista actual a la vista hasta que llega la nueva.
  Future<void> cargar() => _cargar(conEsqueleto: false);

  /// La búsqueda espera 400 ms a que el usuario deje de escribir y pide la página 0 al back.
  void buscar(String valor) {
    if (valor == busqueda) return;
    busqueda = valor;
    _busquedaTimer?.cancel();
    _busquedaTimer = Timer(const Duration(milliseconds: 400), () {
      _cargar(conEsqueleto: false);
    });
  }

  /// Otro tipo son otros datos: se muestra el esqueleto.
  Future<void> cambiarTipo(String id) async {
    if (id == tipoId) return;
    tipoId = id;
    await _cargar(conEsqueleto: true);
  }

  /// Otra prioridad son otros datos: se muestra el esqueleto.
  Future<void> cambiarPrioridad(Prioridad? nueva) async {
    if (nueva == prioridad) return;
    prioridad = nueva;
    await _cargar(conEsqueleto: true);
  }

  /// Otro chip son otros datos: se muestra el esqueleto.
  Future<void> cambiarFiltro(EstadoIncidencia? nuevo) async {
    if (nuevo == filtro) return;
    filtro = nuevo;
    await _cargar(conEsqueleto: true);
  }

  Future<void> _cargar({required bool conEsqueleto}) async {
    // La petición que va a salir ya lleva el texto actual: sobra una búsqueda pendiente.
    _busquedaTimer?.cancel();
    final generacion = ++_generacion;
    if (conEsqueleto || estado is! Listo) {
      estado = const Cargando();
      notifyListeners();
    }

    final res = await _adminRepository.incidencias(
      estado: filtro,
      prioridad: prioridad,
      tipoId: tipoId.isEmpty ? null : tipoId,
      q: busqueda.trim().isEmpty ? null : busqueda.trim(),
    );
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

  /// Siguiente página al llegar al final de la lista, con los mismos filtros.
  Future<void> cargarMas() async {
    if (_esUltima || estado is! Listo || cargandoMas) return;
    cargandoMas = true;
    notifyListeners();
    final generacion = _generacion;

    final res = await _adminRepository.incidencias(
      estado: filtro,
      prioridad: prioridad,
      tipoId: tipoId.isEmpty ? null : tipoId,
      q: busqueda.trim().isEmpty ? null : busqueda.trim(),
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

  @override
  void dispose() {
    _busquedaTimer?.cancel();
    super.dispose();
  }
}
