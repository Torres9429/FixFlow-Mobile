import '../../../domain/repositories/inclinacion_repository.dart';

/// Acelerómetro del modo mock: 60°, válido para los tipos «hacia el suelo» y «sin restricción».
class FakeInclinacionRepository implements InclinacionRepository {
  @override
  Future<double?> leerInclinacion() async => 60;
}
