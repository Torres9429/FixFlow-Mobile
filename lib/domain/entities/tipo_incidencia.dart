/// Hacia dónde debe apuntar el teléfono al tomar la foto (RN-11).
enum OrientacionFoto { suelo, arriba, sinRestriccion }

class TipoIncidencia {
  const TipoIncidencia({
    required this.id,
    required this.nombre,
    this.codigo = '',
    this.orientacion = OrientacionFoto.sinRestriccion,
  });

  final String id;
  final String nombre;

  /// Código fijo del catálogo, por ejemplo `BACHE` (RN-07).
  final String codigo;
  final OrientacionFoto orientacion;
}
