import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../domain/entities/tipo_incidencia.dart';
import '../../../domain/errors/sensor_no_disponible.dart';
import '../../../domain/repositories/inclinacion_repository.dart';
import '../../core/notificador_seguro.dart';

/// ViewModel para la pantalla de cámara en vivo y guía de orientación (B3 / #23 / HU-06).
///
/// Coordina la lectura en tiempo real del acelerómetro, calcula la congruencia con
/// la regla de negocio RN-11 y determina cuándo se habilita el botón disparador.
/// La zona válida sale de `anguloMin`/`anguloMax` del tipo, los mismos con los que valida el servidor.
class CamaraOrientacionViewModel extends ChangeNotifier with NotificadorSeguro {
  CamaraOrientacionViewModel({
    required this.tipo,
    required this.inclinacionRepository,
    this.precisionGps,
    this._sinSensor = false,
  }) {
    if (!_sinSensor) _iniciarMonitoreo();
  }

  /// Si en este tiempo no llega ninguna lectura, el teléfono se trata como sin sensor (respaldo de B2).
  static const esperaPrimeraLectura = Duration(milliseconds: 1500);

  final TipoIncidencia tipo;
  final InclinacionRepository inclinacionRepository;
  final double? precisionGps;

  /// Ventana del promedio al disparar (RN-11).
  static const _ventanaDisparo = Duration(milliseconds: 500);

  StreamSubscription<double>? _subscripcion;
  Timer? _esperaSensor;
  bool _sinSensor;

  /// El teléfono no tiene acelerómetro o no respondió: cámara sin guía y disparador activo (B3e, RN-11).
  bool get sinSensor => _sinSensor;
  double? _anguloActual;

  /// Lecturas recientes con su hora, para promediar el último medio segundo.
  final _lecturas = <(DateTime, double)>[];
  bool _capturando = false;
  String? _error;

  double? get anguloActual => _anguloActual;
  bool get capturando => _capturando;
  String? get error => _error;

  /// Zona válida del tipo; `null` si el servidor no la mandó (entonces decide el servidor al enviar).
  double? get _min => tipo.anguloMin;
  double? get _max => tipo.anguloMax;

  /// Indica si la inclinación actual cumple la regla de negocio del tipo (RN-11).
  bool get enRango {
    if (_sinSensor || tipo.orientacion == OrientacionFoto.sinRestriccion) return true;
    final angulo = _anguloActual;
    if (angulo == null) return false;
    final (min, max) = (_min, _max);
    if (min == null || max == null) return true;
    return angulo >= min && angulo <= max;
  }

  /// Grados que faltan para entrar en la zona verde (0 si ya está en rango).
  int get gradosFaltantes {
    final angulo = _anguloActual;
    final (min, max) = (_min, _max);
    if (angulo == null || min == null || max == null || enRango) return 0;
    return angulo < min ? (min - angulo).round() : (angulo - max).round();
  }

  /// Título de estado para el panel inferior.
  String get estadoTexto {
    if (_sinSensor) return 'Sin sensor de inclinación';
    if (_anguloActual == null) return 'Esperando el sensor de inclinación';
    if (tipo.orientacion == OrientacionFoto.sinRestriccion) {
      return 'Sensores listos';
    }
    if (enRango) {
      return 'Ángulo correcto';
    }
    return switch (tipo.orientacion) {
      OrientacionFoto.suelo => 'Inclina hacia el suelo',
      OrientacionFoto.arriba => 'Inclina hacia arriba',
      OrientacionFoto.sinRestriccion => 'Sensores listos',
    };
  }

  /// Texto explicativo de la zona y los grados restantes (null si no se requiere).
  String? get textoAyuda {
    if (_sinSensor) {
      return 'Encuadra el problema como mejor se vea. La foto se envía sin validar el ángulo.';
    }
    switch (tipo.orientacion) {
      case OrientacionFoto.sinRestriccion:
        return 'Este tipo no pide una orientación: encuadra el problema como mejor se vea. '
            'La inclinación se guarda con la foto.';
      case OrientacionFoto.suelo:
        if (!enRango) {
          return 'Faltan $gradosFaltantes°. El botón se activa al entrar en la zona verde.';
        }
        return null;
      case OrientacionFoto.arriba:
        if (!enRango) {
          return 'Faltan $gradosFaltantes°. Apunta hacia arriba.';
        }
        return null;
    }
  }

  /// Subtítulo para la píldora superior.
  String get subtituloOrientacion {
    if (_sinSensor) return 'sin guía de inclinación';
    return switch (tipo.orientacion) {
      OrientacionFoto.suelo => 'apunta hacia el suelo',
      OrientacionFoto.arriba => 'apunta hacia arriba',
      OrientacionFoto.sinRestriccion => 'cualquier ángulo',
    };
  }

  /// Texto de ayuda en el pie de página bajo el disparador.
  String get textoPie {
    if (_sinSensor) return 'Tu teléfono no tiene sensor de inclinación.';
    if (_anguloActual == null) {
      return 'El botón se activa cuando llegue la primera lectura del sensor.';
    }
    if (!enRango) {
      return 'Inclina el teléfono hasta la zona verde para tomar la foto.';
    }
    if (tipo.orientacion == OrientacionFoto.arriba) {
      return 'Puedes tomarla de lejos: basta con apuntar hacia arriba.';
    }
    return 'Solo se aceptan fotos tomadas en este momento.';
  }

  /// Texto del estado GPS si se tiene precisión.
  String get textoGps {
    final prec = precisionGps?.round();
    if (prec != null) {
      return 'GPS listo • precisión $prec m';
    }
    return 'GPS listo';
  }

  /// El disparador solo se activa con una lectura del sensor, dentro de la zona verde y si no se está capturando.
  bool get disparadorActivo => (_sinSensor || _anguloActual != null) && enRango && !_capturando;

  void _iniciarMonitoreo() {
    // Respaldo: el teléfono dice tener sensor pero no manda lecturas
    _esperaSensor = Timer(esperaPrimeraLectura, () {
      if (_anguloActual == null) _pasarASinSensor();
    });
    try {
      _subscripcion = inclinacionRepository.observarInclinacion().listen(
        (angulo) {
          _anguloActual = angulo;
          _guardarLectura(angulo);
          _error = null;
          notifyListeners();
        },
        onError: (Object err) {
          if (err is SensorNoDisponible) {
            _pasarASinSensor();
            return;
          }
          _error = 'No se pudo leer la inclinación del teléfono.';
          notifyListeners();
        },
      );
    } catch (_) {
      _pasarASinSensor();
    }
  }

  void _pasarASinSensor() {
    if (_sinSensor) return;
    _sinSensor = true;
    _esperaSensor?.cancel();
    _subscripcion?.cancel();
    _error = null;
    notifyListeners();
  }

  void _guardarLectura(double angulo) {
    final ahora = DateTime.now();
    _lecturas.add((ahora, angulo));
    // Basta con conservar un poco más que la ventana del disparo
    _lecturas.removeWhere((l) => ahora.difference(l.$1) > _ventanaDisparo * 2);
  }

  /// Inclinación que se guarda con la foto: el promedio de las lecturas del último medio segundo (RN-11).
  /// `null` si no ha llegado ninguna lectura.
  double? inclinacionDelDisparo() {
    if (_sinSensor) return null;
    final desde = DateTime.now().subtract(_ventanaDisparo);
    final recientes = [for (final (hora, angulo) in _lecturas) if (!hora.isBefore(desde)) angulo];
    if (recientes.isEmpty) return _anguloActual;
    return recientes.reduce((a, b) => a + b) / recientes.length;
  }

  /// Permite fijar un ángulo exacto (para pruebas o control fino).
  void actualizarAnguloManualmente(double angulo) {
    _anguloActual = angulo;
    notifyListeners();
  }

  /// Marca el inicio o fin del proceso de disparo.
  void setCapturando(bool valor) {
    _capturando = valor;
    notifyListeners();
  }

  @override
  void dispose() {
    _esperaSensor?.cancel();
    _subscripcion?.cancel();
    super.dispose();
  }
}

