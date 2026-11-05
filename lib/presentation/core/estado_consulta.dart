/// Estado de una consulta al back: uno a la vez, así no se puede estar «cargando» y «con error» al mismo tiempo.
sealed class EstadoConsulta<T> {
  const EstadoConsulta();
}

final class Cargando<T> extends EstadoConsulta<T> {
  const Cargando();
}

final class Listo<T> extends EstadoConsulta<T> {
  const Listo(this.datos);

  final T datos;
}

final class ConError<T> extends EstadoConsulta<T> {
  const ConError(this.mensaje);

  final String mensaje;
}
