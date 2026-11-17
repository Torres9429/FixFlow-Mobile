import '../../../core/result.dart';
import '../../../domain/entities/estado_incidencia.dart';
import '../../../domain/entities/evento_historial.dart';
import '../../../domain/entities/incidencia_detalle.dart';
import '../../../domain/entities/incidencia_resumen.dart';
import '../../../domain/entities/prioridad.dart';
import '../../../domain/errors/falla_red.dart';
import '../../../domain/repositories/incidencias_repository.dart';
import 'datos_demo.dart';

/// Detalle e historial del modo mock para las incidencias de `DatosDemo`.
/// La 000097 Resuelta trae la foto de la solución y 5 eventos, para ver «Ver todo».
class FakeIncidenciasRepository implements IncidenciasRepository {
  static const _fotoReporte = 'https://res.cloudinary.com/demo/image/upload/sample.jpg';
  static const _fotoSolucion = 'https://res.cloudinary.com/demo/image/upload/samples/landscapes/nature-mountains.jpg';
  static const _solucion = 'Se cambió el tramo de tubería dañado y se selló la toma.';
  static const _motivoReapertura = 'Sigue saliendo agua junto a la banqueta.';

  IncidenciaResumen? _buscar(int id) {
    for (final i in [...DatosDemo.reportesAna, ...DatosDemo.municipio]) {
      if (i.id == id) return i;
    }
    return null;
  }

  static bool _conSolucion(EstadoIncidencia e) =>
      e == EstadoIncidencia.resuelta || e == EstadoIncidencia.cerrada || e == EstadoIncidencia.reabierta;

  @override
  Future<Result<IncidenciaDetalle>> detalle(int id) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final r = _buscar(id);
    if (r == null) return const Result.error(NoEncontrado('La incidencia no existe'));

    final reabierta = r.estado == EstadoIncidencia.reabierta;
    return Result.ok(
      IncidenciaDetalle(
        resumen: r,
        descripcion: switch (r.tipoCodigo) {
          'FUGA_AGUA' => 'Fuga de agua potable visible con escurrimiento continuo sobre la vialidad.',
          'LUMINARIA' => 'La luminaria de la esquina lleva varios días apagada.',
          _ => 'Bache de aproximadamente 60 cm de diámetro en el carril derecho.',
        },
        numReaperturas: reabierta ? 1 : 0,
        // En una reabierta la solución anterior se conserva, pero ya no cuenta como resuelta
        fechaResolucion: _conSolucion(r.estado) && !reabierta ? r.ultimaActualizacion : null,
        fotoReporteUrl: _fotoReporte,
        fotoSolucionUrl: _conSolucion(r.estado) ? _fotoSolucion : null,
        descripcionSolucion: _conSolucion(r.estado) ? _solucion : null,
        motivoReapertura: reabierta ? _motivoReapertura : null,
        // El fake no sabe quién consulta; la pantalla solo lo muestra al admin
        ciudadano: 'Ana López',
        operativoAsignado: r.operativo,
      ),
    );
  }

  @override
  Future<Result<List<EventoHistorial>>> historial(int id) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final r = _buscar(id);
    if (r == null) return const Result.error(NoEncontrado('La incidencia no existe'));

    final operativo = r.operativo ?? 'Luis Ramírez';
    EventoHistorial evento(
      int n,
      AccionHistorial accion,
      String quien, {
      EstadoIncidencia? estado,
      Prioridad? prioridad,
      String? comentario,
    }) => EventoHistorial(
      id: id * 10 + n,
      accion: accion,
      realizadoPor: quien,
      fecha: r.fechaCreacion.add(Duration(hours: n * 6)),
      estadoNuevo: estado,
      prioridadNueva: prioridad,
      operativo: accion == AccionHistorial.asignacion ? r.operativo : null,
      comentario: comentario,
    );

    final atendida = r.estado != EstadoIncidencia.pendiente && r.estado != EstadoIncidencia.asignada;
    return Result.ok([
      evento(0, AccionHistorial.creada, 'Ana López', estado: EstadoIncidencia.pendiente, prioridad: r.prioridad),
      if (r.operativo != null) evento(1, AccionHistorial.asignacion, 'Marta Ruiz', estado: EstadoIncidencia.asignada),
      if (atendida) evento(2, AccionHistorial.cambioEstado, operativo, estado: EstadoIncidencia.enProceso),
      if (_conSolucion(r.estado)) ...[
        evento(
          3,
          AccionHistorial.cambioPrioridad,
          'Sistema',
          prioridad: Prioridad.alta,
          comentario: 'Sin resolver por más de 7 días',
        ),
        evento(4, AccionHistorial.solucion, operativo, estado: EstadoIncidencia.resuelta, comentario: _solucion),
      ],
      if (r.estado == EstadoIncidencia.reabierta)
        evento(5, AccionHistorial.reapertura, 'Ana López', estado: EstadoIncidencia.reabierta, comentario: _motivoReapertura),
    ]);
  }
}
