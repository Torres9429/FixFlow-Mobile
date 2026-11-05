import 'package:flutter/foundation.dart';

import '../../../core/result.dart';
import '../../../domain/entities/coordenada.dart';
import '../../../domain/entities/estado_incidencia.dart';
import '../../../domain/entities/incidencia_resumen.dart';
import '../../../domain/entities/prioridad.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/operativo_repository.dart';
import '../../../domain/repositories/ubicacion_repository.dart';
import '../../core/estado_consulta.dart';
import '../../core/mensajes.dart';
import '../../core/notificador_seguro.dart';

/// D1 Mis asignadas (HU-14): prioridad alta primero y distancia desde el teléfono.
class AsignadasViewModel extends ChangeNotifier with NotificadorSeguro {
  AsignadasViewModel({
    required this._operativoRepository,
    required this._ubicacionRepository,
    required this._authRepository,
  });

  final OperativoRepository _operativoRepository;
  final UbicacionRepository _ubicacionRepository;
  final AuthRepository _authRepository;

  String nombre = '';
  EstadoIncidencia? filtro;
  EstadoConsulta<List<IncidenciaResumen>> estado = const Cargando();
  bool cargandoMas = false;
  Coordenada? _posicion;
  int _pagina = 0;
  bool _esUltima = true;

  List<IncidenciaResumen> get asignadas => switch (estado) {
    Listo(:final datos) => datos,
    _ => const [],
  };

  /// «4 activas · 1 de prioridad alta · 1 reabierta» (design.md, D1).
  String get resumen {
    if (estado is Cargando) return 'Mis asignadas';
    if (asignadas.isEmpty) return 'Sin incidencias activas';
    final altas = asignadas.where((i) => i.prioridad == Prioridad.alta).length;
    final reabiertas = asignadas.where((i) => i.estado == EstadoIncidencia.reabierta).length;
    return [
      '${asignadas.length} ${asignadas.length == 1 ? 'activa' : 'activas'}',
      if (altas > 0) '$altas de prioridad alta',
      if (reabiertas > 0) '$reabiertas ${reabiertas == 1 ? 'reabierta' : 'reabiertas'}',
    ].join(' · ');
  }

  /// «a 1.2 km», o `null` si no hay GPS.
  String? distancia(IncidenciaResumen i) {
    final posicion = _posicion;
    if (posicion == null) return null;
    final km = posicion.distanciaKm(Coordenada(i.latitud, i.longitud));
    return 'a ${km.toStringAsFixed(1)} km';
  }

  Future<void> iniciar() async {
    nombre = await _authRepository.nombreUsuario() ?? '';
    // El GPS no frena la lista: la distancia aparece cuando llega
    _ubicacionRepository.posicionActual().then((p) {
      _posicion = p;
      notifyListeners();
    });
    await cargar();
  }

  /// Al recargar se deja la lista actual a la vista hasta que llega la nueva.
  Future<void> cargar() async {
    if (estado is! Listo) {
      estado = const Cargando();
      notifyListeners();
    }

    final res = await _operativoRepository.asignadas(estado: filtro);
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

  Future<void> cambiarFiltro(EstadoIncidencia? nuevo) async {
    if (nuevo == filtro) return;
    filtro = nuevo;
    estado = const Cargando();
    await cargar();
  }

  Future<void> cargarMas() async {
    if (_esUltima || estado is! Listo || cargandoMas) return;
    cargandoMas = true;
    notifyListeners();

    final res = await _operativoRepository.asignadas(estado: filtro, pagina: _pagina + 1);
    if (res case Ok(:final value)) {
      estado = Listo([...asignadas, ...value.contenido]);
      _pagina = value.numero;
      _esUltima = value.esUltima;
    }
    cargandoMas = false;
    notifyListeners();
  }
}
