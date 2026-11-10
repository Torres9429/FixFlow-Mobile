import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../../domain/repositories/inclinacion_repository.dart';

/// Lectura del acelerómetro promediada en 0.5 s, con la fórmula del spike (S2-04).
///
/// Soporta lectura puntual para revisiones y stream continuo para la guía en vivo (#20 / #23).
class InclinacionDataSource implements InclinacionRepository {
  static const _ventana = Duration(milliseconds: 500);

  @override
  Stream<double> observarInclinacion() {
    try {
      return accelerometerEventStream(samplingPeriod: SensorInterval.uiInterval)
          .map((e) => math.atan2(e.z, math.sqrt(e.x * e.x + e.y * e.y)) * 180 / math.pi);
    } catch (e) {
      debugPrint('[FixFlow] Error al iniciar stream de acelerómetro: $e');
      return const Stream.empty();
    }
  }

  @override
  Future<double?> leerInclinacion() async {
    var sumaX = 0.0, sumaY = 0.0, sumaZ = 0.0;
    var muestras = 0;
    StreamSubscription<AccelerometerEvent>? suscripcion;

    try {
      suscripcion = accelerometerEventStream(samplingPeriod: SensorInterval.gameInterval).listen((e) {
        sumaX += e.x;
        sumaY += e.y;
        sumaZ += e.z;
        muestras++;
      });
      await Future<void>.delayed(_ventana);
    } catch (e) {
      debugPrint('[FixFlow] No se pudo leer el acelerómetro: $e');
    } finally {
      await suscripcion?.cancel();
    }

    if (muestras == 0) return null;
    final x = sumaX / muestras, y = sumaY / muestras, z = sumaZ / muestras;
    // +90 con la cámara trasera hacia el suelo, 0 al horizonte, −90 al cielo
    return math.atan2(z, math.sqrt(x * x + y * y)) * 180 / math.pi;
  }
}
