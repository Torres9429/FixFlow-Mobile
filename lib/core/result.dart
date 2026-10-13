/// Resultado de una operación que puede fallar: [Ok] con el valor o [Error]
/// con un error de dominio (por ejemplo, `CredencialesInvalidas`).
sealed class Result<T> {
  const Result();

  const factory Result.ok(T value) = Ok<T>;
  const factory Result.error(Object error) = Error<T>;
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;
}

final class Error<T> extends Result<T> {
  const Error(this.error);

  final Object error;
}
