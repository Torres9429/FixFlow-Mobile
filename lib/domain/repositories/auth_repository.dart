import '../../core/result.dart';
import '../entities/perfil.dart';
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

  Future<void> cerrarSesion();

  /// Nombre del usuario con sesión, o `null` si no se guardó.
  Future<String?> nombreUsuario();

  Future<Result<Perfil>> miPerfil();

  Future<Result<Perfil>> actualizarPerfil({required String nombre, required String apellidos});

  Future<Result<String?>> cambiarPassword({required String actual, required String nueva});
}
