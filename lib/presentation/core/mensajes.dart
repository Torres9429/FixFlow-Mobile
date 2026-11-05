import '../../domain/errors/falla_red.dart';

/// Lo que lee el usuario cuando algo falla. Dice qué pasó y qué puede hacer; nunca muestra la excepción,
/// el código ni la URL (design.md §8). En los errores de negocio (409, 422, 400) usa el `text` del back.
String mensajePara(Object falla) => switch (falla) {
  Conflicto(:final mensaje?) || EvidenciaInvalida(:final mensaje?) || PeticionRechazada(:final mensaje?) => mensaje,
  SinConexion() => 'No pudimos comunicarnos con FixFlow. Revisa tu internet e intenta de nuevo.',
  TiempoAgotado() => 'FixFlow tardó demasiado en responder. Intenta de nuevo.',
  SesionVencida() => 'Tu sesión terminó. Inicia sesión de nuevo.',
  SinPermiso() => 'No tienes permiso para hacer esto.',
  NoEncontrado() => 'No encontramos lo que buscabas.',
  Conflicto() => 'No se pudo completar: la información cambió. Actualiza e intenta de nuevo.',
  EvidenciaInvalida() => 'La evidencia no es válida. Vuelve a tomar la foto.',
  PeticionRechazada() => 'Revisa los datos e intenta de nuevo.',
  ErrorDelServidor() => 'FixFlow tuvo un problema. Intenta más tarde.',
  RespuestaInvalida() => 'Llegaron datos que no entendemos. Avisa al equipo de desarrollo.',
  _ => 'Algo salió mal. Intenta de nuevo.',
};
