import 'package:flutter/foundation.dart';

import '../../core/result.dart';
import '../../domain/entities/estado_incidencia.dart';
import '../../domain/entities/evento_historial.dart';
import '../../domain/entities/incidencia_detalle.dart';
import '../../domain/errors/falla_red.dart';
import '../../domain/repositories/direccion_repository.dart';
import '../../domain/repositories/incidencias_repository.dart';
import '../../domain/repositories/operativo_repository.dart';
import '../../domain/repositories/reportes_ciudadano_repository.dart';
import '../core/estado_consulta.dart';
import '../core/mensajes.dart';
import '../core/notificador_seguro.dart';
import 'vista_detalle.dart';

/// Detalle y su historial, ya listos para pintar.
typedef DetalleConHistorial = ({
  IncidenciaDetalle detalle,
  List<EventoHistorial> historial,
});

/// C2, D2 y E4: detalle de la incidencia (HU-11) con su historial (HU-22).
class DetalleIncidenciaViewModel extends ChangeNotifier with NotificadorSeguro {
  DetalleIncidenciaViewModel({
    required this.id,
    required this.vista,
    required this._incidenciasRepository,
    required this._direccionRepository,
    required this._operativoRepository,
    required this._reportesRepository,
  });

  /// Con más eventos que estos se muestran los 3 más recientes y «Ver todo» (design.md §7).
  static const maxSinRecortar = 4;
  static const recortados = 3;

  final int id;
  final VistaDetalle vista;
  final IncidenciasRepository _incidenciasRepository;
  final DireccionRepository _direccionRepository;
  final OperativoRepository _operativoRepository;
  final ReportesCiudadanoRepository _reportesRepository;

  EstadoConsulta<DetalleConHistorial> estado = const Cargando();

  /// Dirección escrita; llega después del detalle y mientras tanto se muestran las coordenadas.
  String? direccion;
  bool verTodo = false;
  bool iniciando = false;
  bool confirmando = false;

  /// Solo el admin ve quién reportó (RNF-04). Al ciudadano no le sirve ver su propio nombre.
  bool get mostrarCiudadano => vista == VistaDetalle.admin;

  /// El admin asigna desde el detalle mientras la incidencia puede recibir responsable.
  bool get puedeAsignar => switch (estado) {
    Listo(:final datos) =>
      vista == VistaDetalle.admin &&
          {
            EstadoIncidencia.pendiente,
            EstadoIncidencia.asignada,
            EstadoIncidencia.enProceso,
            EstadoIncidencia.reabierta,
          }.contains(datos.detalle.resumen.estado),
    _ => false,
  };

  /// El operativo puede iniciar atención si la tiene asignada o fue reabierta (HU-15 / RN-14 / #46).
  bool get puedeIniciarAtencion => switch (estado) {
    Listo(:final datos) =>
      vista == VistaDetalle.operativo &&
          (datos.detalle.resumen.estado == EstadoIncidencia.asignada ||
           datos.detalle.resumen.estado == EstadoIncidencia.reabierta),
    _ => false,
  };

  /// El operativo registra la solución cuando la incidencia está En proceso (HU-16 / RN-14 / #70).
  bool get puedeRegistrarSolucion => switch (estado) {
    Listo(:final datos) =>
      vista == VistaDetalle.operativo &&
          datos.detalle.resumen.estado == EstadoIncidencia.enProceso,
    _ => false,
  };

  /// Inicia la atención de la incidencia pasando a `EN_PROCESO` y recarga la ficha.
  Future<Result<void>> iniciarAtencion() async {
    if (iniciando) return const Result.ok(null);
    iniciando = true;
    notifyListeners();
    final res = await _operativoRepository.iniciarAtencion(id);
    iniciando = false;
    if (res is Ok) {
      await iniciar();
    } else {
      notifyListeners();
    }
    return res;
  }

  /// El ciudadano confirma la solución de su reporte cuando está Resuelta (HU-13 / RN-14 / #71).
  bool get puedeConfirmarResolucion => switch (estado) {
    Listo(:final datos) =>
      vista == VistaDetalle.ciudadano && datos.detalle.resumen.estado == EstadoIncidencia.resuelta,
    _ => false,
  };

  /// Confirma la resolución (Resuelta → Cerrada) y recarga la ficha. Devuelve el texto del servidor.
  Future<Result<String>> confirmarResolucion() async {
    if (confirmando) return const Result.error(Conflicto('Ya se está confirmando'));
    confirmando = true;
    notifyListeners();
    final res = await _reportesRepository.confirmarResolucion(id);
    confirmando = false;
    if (res is Ok) {
      await iniciar();
    } else {
      notifyListeners();
    }
    return res;
  }

  bool get tieneResponsable => switch (estado) {
    Listo(:final datos) => datos.detalle.tieneResponsable,
    _ => false,
  };

  List<EventoHistorial> get _historial => switch (estado) {
    Listo(:final datos) => datos.historial,
    _ => const [],
  };

  bool get hayMas => !verTodo && _historial.length > maxSinRecortar;

  /// Del más reciente al más antiguo, recortados si no se pidió «Ver todo».
  List<EventoHistorial> get eventosVisibles =>
      hayMas ? _historial.take(recortados).toList() : _historial;

  /// Primera carga, «Reintentar» y deslizar para recargar. Al recargar, la ficha actual se queda a la vista.
  Future<void> iniciar() async {
    if (estado is ConError) {
      estado = const Cargando();
      notifyListeners();
    }

    final (detalle, historial) = await (
      _incidenciasRepository.detalle(id),
      _incidenciasRepository.historial(id),
    ).wait;

    switch ((detalle, historial)) {
      case (Ok(value: final d), Ok(value: final h)):
        estado = Listo((
          detalle: d,
          historial: h.reversed.toList(growable: false),
        ));
        notifyListeners();
        await _cargarDireccion(d);
      case (Error(:final error), _) || (_, Error(:final error)):
        estado = ConError(mensajePara(error));
        notifyListeners();
    }
  }

  void mostrarTodo() {
    verTodo = true;
    notifyListeners();
  }

  Future<void> _cargarDireccion(IncidenciaDetalle d) async {
    direccion = await _direccionRepository.direccion(
      d.resumen.latitud,
      d.resumen.longitud,
    );
    if (direccion != null) notifyListeners();
  }
}
