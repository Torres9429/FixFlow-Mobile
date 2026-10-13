import '../../core/result.dart';
import '../entities/usuario.dart';

abstract interface class AuthRepository {
  /// Si las credenciales son correctas guarda la sesión y devuelve el usuario.
  /// Si no, devuelve un `AuthFailure`.
  Future<Result<Usuario>> iniciarSesion(String correo, String password);

  Future<void> cerrarSesion();
}
