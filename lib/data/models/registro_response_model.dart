import '../../domain/entities/rol.dart';
import '../../domain/entities/usuario.dart';

/// Respuesta de `POST /usuarios/registro`: el usuario creado viene dentro de `result` (sin token).
class RegistroResponseModel {
  const RegistroResponseModel({required this.rol, required this.nombre});

  factory RegistroResponseModel.fromJson(Map<String, dynamic> json) {
    final r = json['result'] as Map<String, dynamic>;
    return RegistroResponseModel(
      // El rol no se usa después del registro (la app manda al login); si no viene, es ciudadano
      rol: (r['rol'] as String?) ?? (r['role'] as String?) ?? 'CIUDADANO',
      nombre: r['nombre'] as String,
    );
  }

  final String rol;
  final String nombre;

  Usuario toEntity() => Usuario(nombre: nombre, rol: Rol.desde(rol));
}
