import 'accion_aviso.dart';

/// Aviso que llega por push (FCM). Trae lo necesario para abrir la incidencia (HU-12).
class AvisoPush {
  const AvisoPush({required this.incidenciaId, required this.accion, required this.titulo, required this.mensaje});

  final int incidenciaId;
  final AccionAviso accion;
  final String titulo;
  final String mensaje;
}
