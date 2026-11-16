import 'dart:async';

import '../../../domain/errors/sensor_no_disponible.dart';
import '../../../domain/repositories/inclinacion_repository.dart';

/// Acelerómetro del modo mock: 60° por defecto, válido para «hacia el suelo» y «sin restricción».
/// Permite simular inclinaciones arbitrarias para probar la guía visual (#23), y con
/// [conSensor] en `false`, un teléfono sin acelerómetro (B3e).
class FakeInclinacionRepository implements InclinacionRepository {
  FakeInclinacionRepository({double inclinacionInicial = 60, this.conSensor = true})
    : _inclinacion = inclinacionInicial;

  final bool conSensor;
  double _inclinacion;
  StreamController<double>? _controlador;

  void simularInclinacion(double nuevaInclinacion) {
    _inclinacion = nuevaInclinacion;
    _controlador?.add(nuevaInclinacion);
  }

  @override
  Future<bool> sensorDisponible() async => conSensor;

  @override
  Stream<double> observarInclinacion() {
    if (!conSensor) return Stream<double>.error(const SensorNoDisponible());
    _controlador ??= StreamController<double>.broadcast();
    return Stream<double>.multi((emitter) {
      emitter.add(_inclinacion);
      final sub = _controlador!.stream.listen(emitter.add);
      emitter.onCancel = sub.cancel;
    });
  }

  @override
  Future<double?> leerInclinacion() async => conSensor ? _inclinacion : null;
}
