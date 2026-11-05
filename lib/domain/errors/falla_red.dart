/// Fallas al hablar con el back. Llegan a Presentación dentro de un `Result`; nunca un `DioException`.
/// [mensaje] es el `text` que mandó el back, si mandó uno.
sealed class FallaRed {
  const FallaRed([this.mensaje]);

  final String? mensaje;
}

final class SinConexion extends FallaRed {
  const SinConexion();
}

final class TiempoAgotado extends FallaRed {
  const TiempoAgotado();
}

/// 401 después de intentar renovar la sesión.
final class SesionVencida extends FallaRed {
  const SesionVencida([super.mensaje]);
}

/// 403: el rol no puede hacer esto.
final class SinPermiso extends FallaRed {
  const SinPermiso([super.mensaje]);
}

final class NoEncontrado extends FallaRed {
  const NoEncontrado([super.mensaje]);
}

/// 409: dato repetido o transición de estado no válida (RN-14).
final class Conflicto extends FallaRed {
  const Conflicto([super.mensaje]);
}

/// 422: la evidencia no cumple RN-12; hay que repetir la captura.
final class EvidenciaInvalida extends FallaRed {
  const EvidenciaInvalida([super.mensaje]);
}

/// Otro 4xx, normalmente un dato inválido (400).
final class PeticionRechazada extends FallaRed {
  const PeticionRechazada(this.codigo, [super.mensaje]);

  final int codigo;
}

final class ErrorDelServidor extends FallaRed {
  const ErrorDelServidor(this.codigo, [super.mensaje]);

  final int codigo;
}

/// Llegó una respuesta con otra forma de la que dice el contrato.
final class RespuestaInvalida extends FallaRed {
  const RespuestaInvalida();
}
