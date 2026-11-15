import '../../core/result.dart';
import '../entities/usuario.dart';

abstract interface class AuthRepository {
  /// Si las credenciales son correctas guarda la sesión y devuelve el usuario.
  /// Si no, devuelve un `AuthFailure`.
  Future<Result<Usuario>> iniciarSesion(String correo, String password);

  /// Registra un ciudadano nuevo. Si el correo ya existe, devuelve `CorreoDuplicado`.
  Future<Result<Usuario>> registrar({
    required String nombre,
    required String apellidos,
    required String correo,
    required String password,
  });

  /// Cambia la contraseña de la sesión actual (HU-25; útil para reemplazar la temporal de HU-24).
  Future<Result<void>> cambiarPassword({
    required String actual,
    required String nueva,
  });

  Future<void> cerrarSesion();

  /// Nombre del usuario con sesión, o `null` si no se guardó.
  Future<String?> nombreUsuario();
}
