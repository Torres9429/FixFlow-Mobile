import 'rol.dart';

class Perfil {
  const Perfil({
    required this.id,
    required this.nombre,
    required this.apellidos,
    required this.correo,
    required this.rol,
  });

  final int id;
  final String nombre;
  final String apellidos;
  final String correo;
  final Rol rol;

  String get nombreCompleto => [nombre, apellidos].where((p) => p.trim().isNotEmpty).join(' ');

  String get iniciales {
    final primeras = [nombre, apellidos]
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .map((p) => p[0].toUpperCase());
    return primeras.join();
  }
}
