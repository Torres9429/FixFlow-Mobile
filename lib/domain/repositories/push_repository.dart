import '../entities/aviso_push.dart';

/// Notificaciones push (FCM). Nunca falla hacia arriba: sin push, los avisos siguen en la bandeja.
abstract interface class PushRepository {
  /// Pide permiso, registra el token del teléfono en el back y empieza a escuchar.
  Future<void> activar();

  /// Borra el token en el back y en Firebase. Va antes de cerrar sesión.
  Future<void> desactivar();

  /// Avisos que llegan con la app abierta.
  Stream<AvisoPush> get recibidos;

  /// Avisos que el usuario tocó con la app en segundo plano.
  Stream<AvisoPush> get tocados;

  /// El aviso que abrió la app cuando estaba cerrada. Solo lo devuelve una vez.
  Future<AvisoPush?> avisoInicial();
}
