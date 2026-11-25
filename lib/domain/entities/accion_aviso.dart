/// Qué cambio generó el aviso (`accion` del back). Decide a qué pantalla lleva.
enum AccionAviso {
  asignacion,
  reasignacion,
  cambioEstado,
  solucion,
  reapertura,
  otra;

  static AccionAviso desde(String? valor) => switch (valor?.toUpperCase()) {
        'ASIGNACION' => AccionAviso.asignacion,
        'REASIGNACION' => AccionAviso.reasignacion,
        'CAMBIO_ESTADO' => AccionAviso.cambioEstado,
        'SOLUCION' => AccionAviso.solucion,
        'REAPERTURA' => AccionAviso.reapertura,
        _ => AccionAviso.otra,
      };
}
