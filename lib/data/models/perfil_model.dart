import '../../domain/entities/perfil.dart';
import '../../domain/entities/rol.dart';

class PerfilModel {
  const PerfilModel({
    required this.id,
    required this.nombre,
    required this.apellidos,
    required this.correo,
    required this.rol,
  });

  factory PerfilModel.fromJson(Map<String, dynamic> json) {
    final r = json['result'] as Map<String, dynamic>;
    return PerfilModel(
      id: (r['id'] as num).toInt(),
      nombre: r['nombre'] as String? ?? '',
      apellidos: r['apellidos'] as String? ?? '',
      correo: r['correo'] as String? ?? '',
      rol: (r['rol'] as String?) ?? (r['role'] as String?) ?? '',
    );
  }

  final int id;
  final String nombre;
  final String apellidos;
  final String correo;
  final String rol;

  Perfil toEntity() => Perfil(id: id, nombre: nombre, apellidos: apellidos, correo: correo, rol: Rol.desde(rol));
}
