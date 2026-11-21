import 'package:flutter/foundation.dart';

import '../../core/result.dart';
import '../../domain/entities/coordenada.dart';
import '../../domain/entities/reporte_nuevo.dart';
import '../../domain/entities/tipo_incidencia.dart';
import '../../domain/repositories/incidence_type_repository.dart';
import '../../domain/repositories/inclinacion_repository.dart';
import '../../domain/repositories/ubicacion_repository.dart';
import '../core/estado_consulta.dart';
import '../core/mensajes.dart';
import '../core/notificador_seguro.dart';
import 'camara/resultado_captura.dart';

/// B2 Nuevo reporte, paso 1 (HU-03): tipos activos, tipo elegido, GPS, sensor de inclinación y la captura.
/// La pantalla solo guarda el formulario (descripción) y navega a la cámara y a B4.
class NuevoReporteViewModel extends ChangeNotifier with NotificadorSeguro {
  NuevoReporteViewModel({
    required this._tiposRepository,
    required this._ubicacionRepository,
    required this._inclinacionRepository,
  });

  final IncidenceTypeRepository _tiposRepository;
  final UbicacionRepository _ubicacionRepository;
  final InclinacionRepository _inclinacionRepository;

  /// Tipos activos del catálogo (RN-07).
  EstadoConsulta<List<TipoIncidencia>> tipos = const Cargando();
  TipoIncidencia? tipo;

  /// El teléfono no tiene acelerómetro: se avisa y la foto va sin validar el ángulo (RN-11, B3e).
  bool sinSensor = false;

  /// GPS del teléfono; obligatorio para continuar (HU-05).
  Coordenada? posicion;
  bool cargandoUbicacion = true;
  String? errorUbicacion;

  /// La última captura de la cámara; se descarta al volver de B4 para tomar una nueva.
  ResultadoCaptura? captura;

  /// Tipos, GPS y sensor a la vez: ninguno espera al otro.
  Future<void> iniciar() async {
    await (cargarTipos(), cargarUbicacion(), _revisarSensor()).wait;
  }

  Future<void> cargarTipos() async {
    tipos = const Cargando();
    notifyListeners();
    tipos = switch (await _tiposRepository.obtenerTipos()) {
      Ok(:final value) => Listo(value),
      Error(error: final falla) => ConError(mensajePara(falla)),
    };
    notifyListeners();
  }

  Future<void> cargarUbicacion() async {
    cargandoUbicacion = true;
    errorUbicacion = null;
    notifyListeners();
    posicion = await _ubicacionRepository.posicionActual();
    cargandoUbicacion = false;
    errorUbicacion = posicion == null ? 'No se pudo obtener la ubicación GPS.' : null;
    notifyListeners();
  }

  Future<void> _revisarSensor() async {
    if (await _inclinacionRepository.sensorDisponible()) return;
    sinSensor = true;
    notifyListeners();
  }

  void elegirTipo(TipoIncidencia nuevo) {
    tipo = nuevo;
    notifyListeners();
  }

  /// Por qué todavía no se puede continuar sin GPS; `null` si ya hay posición.
  /// Si el GPS falló, vuelve a intentarlo para la siguiente vez.
  String? motivoSinUbicacion() {
    if (posicion != null) return null;
    if (cargandoUbicacion) return 'Todavía estamos obteniendo tu ubicación. Intenta en un momento.';
    cargarUbicacion();
    return 'La ubicación GPS es obligatoria para enviar el reporte. Actívala e intenta de nuevo.';
  }

  void guardarCaptura(ResultadoCaptura nueva) {
    captura = nueva;
    // El respaldo de la cámara puede descubrir que el sensor no responde
    sinSensor = sinSensor || nueva.sinSensor;
    notifyListeners();
  }

  /// Al regresar de B4, la siguiente vez se toma una foto nueva.
  void limpiarCaptura() {
    captura = null;
    notifyListeners();
  }

  /// El reporte para B4 con la captura actual. Requiere tipo, posición y captura.
  Future<ReporteNuevo> armarReporte(String descripcion) async {
    final c = captura!;
    // Inclinación del disparo (RN-11); sin acelerómetro no hay lectura
    final inclinacion = sinSensor ? null : c.inclinacion ?? await _inclinacionRepository.leerInclinacion();
    return ReporteNuevo(
      tipo: tipo!,
      descripcion: descripcion.trim(),
      latitud: posicion!.latitud,
      longitud: posicion!.longitud,
      inclinacion: inclinacion,
      sinSensor: sinSensor,
      rutaFoto: c.rutaFoto,
      capturadaEn: c.capturadaEn,
    );
  }
}
