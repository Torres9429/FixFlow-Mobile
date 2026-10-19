import '../../domain/entities/rol.dart';
import '../../domain/entities/usuario.dart';

/// Respuesta de `POST /auth/registro`: `{ "token", "rol", "nombre" }`.
class RegistroResponseModel {
  const RegistroResponseModel({required this.token, required this.rol, required this.nombre});

  factory RegistroResponseModel.fromJson(Map<String, dynamic> json) => RegistroResponseModel(
        token: json['token'] as String,
        rol: json['rol'] as String,
        nombre: json['nombre'] as String? ?? '',
      );

  final String token;
  final String rol;
  final String nombre;

  Usuario toEntity() => Usuario(nombre: nombre, rol: Rol.desde(rol));
}
