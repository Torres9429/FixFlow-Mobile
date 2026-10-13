enum Rol {
  ciudadano,
  operativo,
  admin,
  desconocido;

  /// Convierte el rol que manda el back (`CIUDADANO`, `OPERATIVO`, `ADMIN`).
  static Rol desde(String? valor) => switch (valor?.toUpperCase()) {
        'CIUDADANO' => Rol.ciudadano,
        'OPERATIVO' => Rol.operativo,
        'ADMIN' => Rol.admin,
        _ => Rol.desconocido,
      };
}
