import 'dart:async';

import '../../../domain/repositories/inclinacion_repository.dart';

/// Acelerómetro del modo mock: 60° por defecto, válido para «hacia el suelo» y «sin restricción».
/// Permite simular inclinaciones arbitrarias para probar la guía visual (#23).
class FakeInclinacionRepository implements InclinacionRepository {
  FakeInclinacionRepository({double inclinacionInicial = 60}) : _inclinacion = inclinacionInicial;

  double _inclinacion;
  StreamController<double>? _controlador;

  void simularInclinacion(double nuevaInclinacion) {
    _inclinacion = nuevaInclinacion;
    _controlador?.add(nuevaInclinacion);
  }

  @override
  Stream<double> observarInclinacion() {
    _controlador ??= StreamController<double>.broadcast();
    return Stream<double>.multi((emitter) {
      emitter.add(_inclinacion);
      final sub = _controlador!.stream.listen(emitter.add);
      emitter.onCancel = sub.cancel;
    });
  }

  @override
  Future<double?> leerInclinacion() async => _inclinacion;
}
