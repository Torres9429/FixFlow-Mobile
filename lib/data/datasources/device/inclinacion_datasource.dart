import 'dart:async';
import 'dart:math' as math;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../../domain/errors/sensor_no_disponible.dart';
import '../../../domain/repositories/inclinacion_repository.dart';

/// Lectura del acelerómetro promediada en 0.5 s, con la fórmula del spike (S2-04).
///
/// Lectura puntual para revisiones y stream continuo para la guía en vivo. Antes de capturar,
/// [sensorDisponible] dice si el teléfono tiene acelerómetro (RN-11).
class InclinacionDataSource implements InclinacionRepository {
  InclinacionDataSource({DeviceInfoPlugin? deviceInfo}) : _deviceInfo = deviceInfo ?? DeviceInfoPlugin();

  final DeviceInfoPlugin _deviceInfo;

  static const _ventana = Duration(milliseconds: 500);
  static const _esperaPrimeraLectura = Duration(seconds: 1);
  static const _featureAcelerometro = 'android.hardware.sensor.accelerometer';

  /// Primero se le pregunta a Android qué sensores declara el teléfono. Si eso falla,
  /// se escucha el sensor: sin una lectura en 1 s (o con el error `NO_SENSOR`), no hay sensor.
  @override
  Future<bool> sensorDisponible() async {
    try {
      final info = await _deviceInfo.androidInfo;
      return info.systemFeatures.contains(_featureAcelerometro);
    } catch (e) {
      debugPrint('[FixFlow] No se pudo consultar systemFeatures; se prueba el sensor: $e');
      return _respondeElSensor();
    }
  }

  Future<bool> _respondeElSensor() async {
    try {
      await accelerometerEventStream().first.timeout(_esperaPrimeraLectura);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Stream<double> observarInclinacion() {
    try {
      return accelerometerEventStream(samplingPeriod: SensorInterval.uiInterval)
          .map((e) => _grados(e.x, e.y, e.z))
          // sensors_plus manda un PlatformException «NO_SENSOR» si falta el sensor; hacia arriba viaja uno de dominio
          .transform(
            StreamTransformer<double, double>.fromHandlers(
              handleError: (error, stack, sink) {
                debugPrint('[FixFlow] Acelerómetro no disponible: $error');
                sink.addError(const SensorNoDisponible());
              },
            ),
          );
    } catch (e) {
      debugPrint('[FixFlow] Error al iniciar el acelerómetro: $e');
      return Stream<double>.error(const SensorNoDisponible());
    }
  }

  @override
  Future<double?> leerInclinacion() async {
    var sumaX = 0.0, sumaY = 0.0, sumaZ = 0.0;
    var muestras = 0;
    StreamSubscription<AccelerometerEvent>? suscripcion;

    try {
      suscripcion = accelerometerEventStream(samplingPeriod: SensorInterval.gameInterval).listen(
        (e) {
          sumaX += e.x;
          sumaY += e.y;
          sumaZ += e.z;
          muestras++;
        },
        onError: (Object e) => debugPrint('[FixFlow] No se pudo leer el acelerómetro: $e'),
      );
      await Future<void>.delayed(_ventana);
    } catch (e) {
      debugPrint('[FixFlow] No se pudo leer el acelerómetro: $e');
    } finally {
      await suscripcion?.cancel();
    }

    if (muestras == 0) return null;
    return _grados(sumaX / muestras, sumaY / muestras, sumaZ / muestras);
  }

  /// +90 con la cámara trasera hacia el suelo, 0 al horizonte, −90 al cielo.
  static double _grados(double x, double y, double z) => math.atan2(z, math.sqrt(x * x + y * y)) * 180 / math.pi;
}
