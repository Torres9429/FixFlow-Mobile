import 'package:flutter/foundation.dart';

import '../../../core/result.dart';
import '../../../domain/entities/estado_incidencia.dart';
import '../../../domain/entities/incidencia_resumen.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/reportes_ciudadano_repository.dart';
import '../../core/estado_consulta.dart';
import '../../core/mensajes.dart';
import '../../core/notificador_seguro.dart';

/// B1 Mis reportes y C4 sin reportes (HU-10).
class MisReportesViewModel extends ChangeNotifier with NotificadorSeguro {
  MisReportesViewModel({required this._reportesRepository, required this._authRepository});

  final ReportesCiudadanoRepository _reportesRepository;
  final AuthRepository _authRepository;

  String nombre = '';
  EstadoIncidencia? filtro;
  EstadoConsulta<List<IncidenciaResumen>> estado = const Cargando();
  bool cargandoMas = false;
  int _pagina = 0;
  bool _esUltima = true;

  /// Si el ciudadano tiene al menos un reporte, aunque el filtro actual no muestre ninguno.
  bool _tieneReportes = false;

  List<IncidenciaResumen> get _cargados => switch (estado) {
    Listo(:final datos) => datos,
    _ => const [],
  };

  /// El back todavía no filtra `/incidencias/mias` por estado; se filtra también aquí.
  List<IncidenciaResumen> get reportes =>
      filtro == null ? _cargados : _cargados.where((r) => r.estado == filtro).toList(growable: false);

  /// C4: el ciudadano no tiene ningún reporte (no es un filtro vacío).
  bool get sinReportes => estado is Listo && filtro == null && _cargados.isEmpty;

  /// Los chips aparecen cuando hay al menos un reporte, o si ya hay un filtro elegido (para poder quitarlo).
  bool get mostrarFiltros => filtro != null || _tieneReportes;

  Future<void> iniciar() async {
    nombre = await _authRepository.nombreUsuario() ?? '';
    await cargar();
  }

  /// Al recargar se deja la lista actual a la vista hasta que llega la nueva.
  Future<void> cargar() async {
    if (estado is! Listo) {
      estado = const Cargando();
      notifyListeners();
    }

    final res = await _reportesRepository.misReportes(estado: filtro);
    switch (res) {
      case Ok(:final value):
        estado = Listo(value.contenido);
        _pagina = value.numero;
        _esUltima = value.esUltima;
        if (filtro == null || value.contenido.isNotEmpty) _tieneReportes = value.contenido.isNotEmpty;
      case Error(error: final falla):
        estado = ConError(mensajePara(falla));
    }
    notifyListeners();
  }

  Future<void> cambiarFiltro(EstadoIncidencia? nuevo) async {
    if (nuevo == filtro) return;
    filtro = nuevo;
    // Otro filtro son otros datos: se muestra el esqueleto
    estado = const Cargando();
    await cargar();
  }

  /// Siguiente página al llegar al final de la lista.
  Future<void> cargarMas() async {
    if (_esUltima || estado is! Listo || cargandoMas) return;
    cargandoMas = true;
    notifyListeners();

    final res = await _reportesRepository.misReportes(estado: filtro, pagina: _pagina + 1);
    if (res case Ok(:final value)) {
      estado = Listo([..._cargados, ...value.contenido]);
      _pagina = value.numero;
      _esUltima = value.esUltima;
    }
    cargandoMas = false;
    notifyListeners();
  }
}
