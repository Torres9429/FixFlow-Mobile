import '../../domain/entities/rol.dart';
import '../../domain/entities/usuario.dart';

/// Respuesta de `POST /auth/login`: `{ "token", "rol", "nombre" }`.
class LoginResponseModel {
  const LoginResponseModel({required this.token, required this.rol, required this.nombre});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) => LoginResponseModel(
        token: json['token'] as String,
        rol: json['rol'] as String,
        nombre: json['nombre'] as String? ?? '',
      );

  final String token;
  final String rol;
  final String nombre;

  Usuario toEntity() => Usuario(nombre: nombre, rol: Rol.desde(rol));
}
