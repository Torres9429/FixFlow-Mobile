import 'package:flutter/foundation.dart';

import '../../../core/result.dart';
import '../../../domain/entities/tipo_incidencia.dart';
import '../../../domain/repositories/incidence_type_repository.dart';
import '../../core/estado_consulta.dart';
import '../../core/mensajes.dart';
import '../../core/notificador_seguro.dart';

enum FiltroTipos { todos, activos, inactivos }

/// E10 Catálogo de tipos: todos los tipos, activos e inactivos (HU-26).
class CatalogoTiposViewModel extends ChangeNotifier with NotificadorSeguro {
  CatalogoTiposViewModel({required this._tiposRepository});

  final IncidenceTypeRepository _tiposRepository;

  EstadoConsulta<List<TipoIncidencia>> estado = const Cargando();
  FiltroTipos filtro = FiltroTipos.todos;

  /// El tipo al que se le está cambiando el estatus; su botón muestra el indicador.
  String? actualizandoId;
  String? error;

  List<TipoIncidencia> get tipos => switch (estado) {
    Listo(:final datos) => datos,
    _ => const [],
  };

  int get activos => tipos.where((t) => t.activo).length;
  int get inactivos => tipos.length - activos;

  int cantidad(FiltroTipos f) => switch (f) {
    FiltroTipos.todos => tipos.length,
    FiltroTipos.activos => activos,
    FiltroTipos.inactivos => inactivos,
  };

  List<TipoIncidencia> get visibles => tipos
      .where(
        (t) => switch (filtro) {
          FiltroTipos.todos => true,
          FiltroTipos.activos => t.activo,
          FiltroTipos.inactivos => !t.activo,
        },
      )
      .toList(growable: false);

  /// Al recargar se deja la lista actual a la vista hasta que llega la nueva.
  Future<void> cargar() async {
    if (estado is! Listo) {
      estado = const Cargando();
      notifyListeners();
    }
    estado = switch (await _tiposRepository.catalogo()) {
      Ok(value: final tipos) => Listo(tipos),
      Error(error: final falla) => ConError(mensajePara(falla)),
    };
    notifyListeners();
  }

  void filtrar(FiltroTipos valor) {
    filtro = valor;
    notifyListeners();
  }

  /// Desactiva o reactiva el tipo, después de confirmar (E12a). Devuelve `true` si el servidor lo guardó.
  Future<bool> cambiarEstatus(TipoIncidencia tipo) async {
    actualizandoId = tipo.id;
    error = null;
    notifyListeners();
    final resultado = await _tiposRepository.cambiarEstatus(tipo.id, activo: !tipo.activo);
    actualizandoId = null;
    if (resultado case Error(error: final falla)) {
      error = mensajePara(falla);
      notifyListeners();
      return false;
    }
    await cargar();
    return true;
  }
}
