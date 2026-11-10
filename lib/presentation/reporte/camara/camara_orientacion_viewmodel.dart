import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../domain/entities/tipo_incidencia.dart';
import '../../../domain/repositories/inclinacion_repository.dart';

/// ViewModel para la pantalla de cámara en vivo y guía de orientación (B3 / #23 / HU-06).
///
/// Coordina la lectura en tiempo real del acelerómetro, calcula la congruencia con
/// la regla de negocio RN-11 y determina cuándo se habilita el botón disparador.
class CamaraOrientacionViewModel extends ChangeNotifier {
  CamaraOrientacionViewModel({
    required this.tipo,
    required this.inclinacionRepository,
    this.precisionGps,
  }) {
    _iniciarMonitoreo();
  }

  static const double sueloMinimo = 45.0;
  static const double arribaMaximo = -20.0;

  final TipoIncidencia tipo;
  final InclinacionRepository inclinacionRepository;
  final double? precisionGps;

  StreamSubscription<double>? _subscripcion;
  double? _anguloActual;
  bool _capturando = false;
  String? _error;

  double? get anguloActual => _anguloActual;
  bool get capturando => _capturando;
  String? get error => _error;

  /// Indica si la inclinación actual cumple la regla de negocio del tipo (RN-11).
  bool get enRango {
    final angulo = _anguloActual;
    switch (tipo.orientacion) {
      case OrientacionFoto.suelo:
        return angulo != null && angulo >= sueloMinimo;
      case OrientacionFoto.arriba:
        return angulo != null && angulo <= arribaMaximo;
      case OrientacionFoto.sinRestriccion:
        return true;
    }
  }

  /// Grados que faltan para entrar en la zona verde (0 si ya está en rango).
  int get gradosFaltantes {
    final angulo = _anguloActual;
    if (angulo == null) return 0;
    switch (tipo.orientacion) {
      case OrientacionFoto.suelo:
        return angulo < sueloMinimo ? (sueloMinimo - angulo).round() : 0;
      case OrientacionFoto.arriba:
        return angulo > arribaMaximo ? (angulo - arribaMaximo).round() : 0;
      case OrientacionFoto.sinRestriccion:
        return 0;
    }
  }

  /// Título de estado para el panel inferior.
  String get estadoTexto {
    if (tipo.orientacion == OrientacionFoto.sinRestriccion) {
      return '✓ Sensores listos';
    }
    if (enRango) {
      return '✓ Ángulo correcto';
    }
    return switch (tipo.orientacion) {
      OrientacionFoto.suelo => 'Inclina hacia el suelo',
      OrientacionFoto.arriba => 'Inclina hacia arriba',
      OrientacionFoto.sinRestriccion => '✓ Sensores listos',
    };
  }

  /// Texto explicativo de la zona y los grados restantes (null si no se requiere).
  String? get textoAyuda {
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
    return switch (tipo.orientacion) {
      OrientacionFoto.suelo => 'apunta hacia el suelo',
      OrientacionFoto.arriba => 'apunta hacia arriba',
      OrientacionFoto.sinRestriccion => 'cualquier ángulo',
    };
  }

  /// Texto de ayuda en el pie de página bajo el disparador.
  String get textoPie {
    if (!enRango) {
      return 'Inclina el teléfono para continuar (en el prototipo, toca el botón para simularlo).';
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

  /// El disparador solo se activa dentro de la zona verde y si no se está capturando.
  bool get disparadorActivo => enRango && !_capturando;

  void _iniciarMonitoreo() {
    try {
      _subscripcion = inclinacionRepository.observarInclinacion().listen(
        (angulo) {
          _anguloActual = angulo;
          _error = null;
          notifyListeners();
        },
        onError: (Object err) {
          _error = 'Error al leer la orientación del dispositivo: $err';
          notifyListeners();
        },
      );
    } catch (e) {
      _error = 'Sensor de inclinación no disponible: $e';
      notifyListeners();
    }
  }

  /// Permite a emuladores y pruebas simular el ángulo correcto con un toque.
  void simularAnguloValido() {
    _anguloActual = switch (tipo.orientacion) {
      OrientacionFoto.suelo => 62.0,
      OrientacionFoto.arriba => -35.0,
      OrientacionFoto.sinRestriccion => 5.0,
    };
    notifyListeners();
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
    _subscripcion?.cancel();
    super.dispose();
  }
}

