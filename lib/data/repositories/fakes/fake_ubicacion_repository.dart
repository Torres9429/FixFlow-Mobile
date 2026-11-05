import '../../../domain/entities/coordenada.dart';
import '../../../domain/repositories/ubicacion_repository.dart';

/// GPS del modo mock: siempre en el centro de Cuernavaca.
class FakeUbicacionRepository implements UbicacionRepository {
  @override
  Future<Coordenada?> posicionActual() async => const Coordenada(18.9220, -99.2340);
}
