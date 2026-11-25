import 'accion_aviso.dart';

/// Un aviso de la bandeja (C1, D6, E7). El texto lo arma el servidor (design.md, Avisos).
class Aviso {
  const Aviso({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.leida,
    required this.fecha,
    required this.incidenciaId,
    required this.folio,
    required this.accion,
  });

  final int id;
  final String titulo;
  final String mensaje;
  final bool leida;
  final DateTime fecha;

  /// Para abrir el detalle al tocarlo (HU-12).
  final int incidenciaId;
  final String folio;
  final AccionAviso accion;

  Aviso leido() => Aviso(
    id: id,
    titulo: titulo,
    mensaje: mensaje,
    leida: true,
    fecha: fecha,
    incidenciaId: incidenciaId,
    folio: folio,
    accion: accion,
  );
}
