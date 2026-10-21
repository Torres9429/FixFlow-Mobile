import '../../domain/entities/rol.dart';
import '../../domain/entities/usuario.dart';

/// Respuesta de `POST /auth/login` y `/auth/refresh`: los datos vienen dentro de `result`.
class LoginResponseModel {
  const LoginResponseModel({
    required this.token,
    required this.refreshToken,
    required this.userId,
    required this.rol,
    required this.nombre,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final r = json['result'] as Map<String, dynamic>;
    return LoginResponseModel(
      token: r['jwt'] as String,
      refreshToken: r['refreshToken'] as String,
      userId: (r['userId'] as num).toInt(),
      rol: r['role'] as String,
      nombre: r['nombre'] as String? ?? '',
    );
  }

  final String token;
  final String refreshToken;
  final int userId;
  final String rol;
  final String nombre;

  Usuario toEntity() => Usuario(nombre: nombre, rol: Rol.desde(rol));
}
