/// Errores de autenticación que llegan a Presentación (nunca un `DioException`).
sealed class AuthFailure {
  const AuthFailure();
}

final class CredencialesInvalidas extends AuthFailure {
  const CredencialesInvalidas();
}

final class SinConexion extends AuthFailure {
  const SinConexion();
}

final class ErrorDesconocido extends AuthFailure {
  const ErrorDesconocido();
}
