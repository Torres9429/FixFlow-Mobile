/// Errores propios del acceso. Las fallas de red (sin conexión, servidor…) son `FallaRed`.
sealed class AuthFailure {
  const AuthFailure();
}

final class CredencialesInvalidas extends AuthFailure {
  const CredencialesInvalidas();
}

final class CorreoDuplicado extends AuthFailure {
  const CorreoDuplicado();
}
