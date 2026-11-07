import 'package:flutter/material.dart';

import '../../../domain/entities/evento_historial.dart';
import '../../core/formato_fecha.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/estado_chip.dart';
import 'encabezado_detalle.dart';
import 'seccion.dart';

/// Línea de tiempo del historial (HU-22, design.md §7): punto del color del estado nuevo, título,
/// comentario y «29 oct, 14:00 · Luis Ramírez». Los más recientes arriba.
class HistorialDetalle extends StatelessWidget {
  const HistorialDetalle({super.key, required this.eventos, required this.hayMas, required this.onVerTodo});

  final List<EventoHistorial> eventos;
  final bool hayMas;
  final VoidCallback onVerTodo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TituloSeccion('Historial de atención'),
        BloqueSeccion(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, e) in eventos.indexed) _Evento(evento: e, ultimo: i == eventos.length - 1 && !hayMas),
              if (hayMas)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    key: const Key('historial_ver_todo'),
                    onPressed: onVerTodo,
                    child: const Text('Ver todo'),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Evento extends StatelessWidget {
  const _Evento({required this.evento, required this.ultimo});

  final EventoHistorial evento;

  /// El último no lleva línea hacia abajo.
  final bool ultimo;

  @override
  Widget build(BuildContext context) {
    final color = evento.estadoNuevo == null ? AppColors.placeholder : coloresEstado(evento.estadoNuevo!).$3;
    final comentario = evento.comentario;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 10,
            child: Column(
              children: [
                const SizedBox(height: 6),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                if (!ultimo) Expanded(child: Container(width: 2, color: AppColors.borderSubtle)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tituloEvento(evento),
                    style: estiloCuerpo(context)?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (comentario != null && comentario.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(comentario, style: estiloCuerpo(context, color: AppColors.textSecondary)),
                  ],
                  const SizedBox(height: 2),
                  Text('${formatearFechaSinAnio(evento.fecha)} · ${evento.realizadoPor}', style: estiloMeta(context)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// «Pasó a En proceso», «Asignada a Luis Ramírez», «Solución registrada»…
String tituloEvento(EventoHistorial e) => switch (e.accion) {
  AccionHistorial.creada => 'Reporte creado',
  AccionHistorial.asignacion => e.operativo == null ? 'Asignada' : 'Asignada a ${e.operativo}',
  AccionHistorial.reasignacion => e.operativo == null ? 'Reasignada' : 'Reasignada a ${e.operativo}',
  AccionHistorial.cambioEstado => e.estadoNuevo == null ? 'Cambio de estado' : 'Pasó a ${coloresEstado(e.estadoNuevo!).$1}',
  AccionHistorial.solucion => 'Solución registrada',
  AccionHistorial.reapertura => 'Reabierta',
  AccionHistorial.cambioPrioridad =>
    e.prioridadNueva == null ? 'Cambio de prioridad' : 'Pasó a ${textoPrioridad(e.prioridadNueva!).toLowerCase()}',
};
