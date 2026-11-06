import '../../../domain/repositories/direccion_repository.dart';

/// Dirección del modo mock: la de los datos de ejemplo de design.md §9.
class FakeDireccionRepository implements DireccionRepository {
  @override
  Future<String?> direccion(double latitud, double longitud) async => 'Calle Morelos 892, Centro';
}
