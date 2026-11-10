import 'package:flutter/foundation.dart';

import '../../core/result.dart';
import '../../domain/entities/estado_incidencia.dart';
import '../../domain/entities/evento_historial.dart';
import '../../domain/entities/incidencia_detalle.dart';
import '../../domain/repositories/direccion_repository.dart';
import '../../domain/repositories/incidencias_repository.dart';
import '../core/estado_consulta.dart';
import '../core/mensajes.dart';
import '../core/notificador_seguro.dart';
import 'vista_detalle.dart';

/// Detalle y su historial, ya listos para pintar.
typedef DetalleConHistorial = ({
  IncidenciaDetalle detalle,
  List<EventoHistorial> historial,
});

/// C2, D2 y E4: detalle de la incidencia (HU-11) con su historial (HU-22). Sin acciones en este sprint.
class DetalleIncidenciaViewModel extends ChangeNotifier with NotificadorSeguro {
  DetalleIncidenciaViewModel({
    required this.id,
    required this.vista,
    required this._incidenciasRepository,
    required this._direccionRepository,
  });

  /// Con más eventos que estos se muestran los 3 más recientes y «Ver todo» (design.md §7).
  static const maxSinRecortar = 4;
  static const recortados = 3;

  final int id;
  final VistaDetalle vista;
  final IncidenciasRepository _incidenciasRepository;
  final DireccionRepository _direccionRepository;

  EstadoConsulta<DetalleConHistorial> estado = const Cargando();

  /// Dirección escrita; llega después del detalle y mientras tanto se muestran las coordenadas.
  String? direccion;
  bool verTodo = false;

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
