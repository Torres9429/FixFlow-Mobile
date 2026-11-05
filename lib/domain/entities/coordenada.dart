import 'dart:math';

class Coordenada {
  const Coordenada(this.latitud, this.longitud);

  final double latitud;
  final double longitud;

  /// Distancia en línea recta (haversine), en km. Sirve para «a 1.2 km» en D1 y D5.
  double distanciaKm(Coordenada otra) {
    const radioTierraKm = 6371.0;
    double rad(double grados) => grados * pi / 180;

    final dLat = rad(otra.latitud - latitud);
    final dLng = rad(otra.longitud - longitud);
    final a = pow(sin(dLat / 2), 2) + cos(rad(latitud)) * cos(rad(otra.latitud)) * pow(sin(dLng / 2), 2);
    return radioTierraKm * 2 * atan2(sqrt(a), sqrt(1 - a));
  }
}
