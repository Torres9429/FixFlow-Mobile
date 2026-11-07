/// Dirección escrita a partir de coordenadas; la calcula el teléfono (design.md §2).
abstract interface class DireccionRepository {
  /// «Calle Morelos 892, Centro», o `null` si no se pudo calcular.
  Future<String?> direccion(double latitud, double longitud);
}
