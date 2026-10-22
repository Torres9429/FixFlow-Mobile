import '../../domain/entities/rol.dart';
import '../../domain/entities/usuario.dart';

/// Respuesta de `POST /usuarios/registro`: los datos del usuario vienen dentro de `result` (sin token).
class RegistroResponseModel {
  const RegistroResponseModel({required this.rol, required this.nombre});

  factory RegistroResponseModel.fromJson(Map<String, dynamic> json) {
    final r = json['result'] is Map<String, dynamic>
        ? json['result'] as Map<String, dynamic>
        : json;
    return RegistroResponseModel(
      rol: (r['rol'] as String?) ?? (r['role'] as String?) ?? 'CIUDADANO',
      nombre: (r['nombre'] as String?) ?? '',
    );
  }

  final String rol;
  final String nombre;

  Usuario toEntity() => Usuario(nombre: nombre, rol: Rol.desde(rol));
}
