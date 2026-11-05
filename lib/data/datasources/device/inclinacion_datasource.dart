import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../../domain/repositories/inclinacion_repository.dart';

/// Lectura del acelerómetro promediada en 0.5 s, con la fórmula del spike (S2-04).
///
/// PROVISIONAL: hoy se lee al volver de la cámara de `image_picker`. Cuando entre la cámara en vivo
/// (#20) con su guía (#23), la lectura será la del momento del disparo y esta clase se usará desde ahí.
class InclinacionDataSource implements InclinacionRepository {
  static const _ventana = Duration(milliseconds: 500);

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
