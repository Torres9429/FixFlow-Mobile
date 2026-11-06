import 'package:flutter/material.dart';

import '../../../domain/entities/incidencia_detalle.dart';
import '../../../domain/entities/prioridad.dart';
import '../../core/formato_fecha.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/estado_chip.dart';
import '../../core/widgets/prioridad_simbolo.dart';
import 'seccion.dart';

/// Estado, prioridad con su motivo, tipo, folio con la fecha y descripción (design.md §7, Secciones del detalle).
class EncabezadoDetalle extends StatelessWidget {
  const EncabezadoDetalle({super.key, required this.detalle});

  final IncidenciaDetalle detalle;

  @override
  Widget build(BuildContext context) {
    final r = detalle.resumen;
    final texto = Theme.of(context).textTheme;

    return BloqueSeccion(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              EstadoChip(estado: r.estado),
              const Spacer(),
              // Prioridad: símbolo de barras + texto, nunca píldora
              PrioridadSimbolo(prioridad: r.prioridad),
              const SizedBox(width: 6),
              Text(
                textoPrioridad(r.prioridad),
                style: texto.bodyLarge?.copyWith(fontSize: 15, height: 22 / 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          if (r.motivoPrioridad.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: Text(r.motivoPrioridad, key: const Key('detalle_motivo'), style: estiloMeta(context)),
            ),
          const SizedBox(height: 12),
          Text(
            r.tipo,
            style: texto.headlineSmall?.copyWith(fontSize: 24, height: 30 / 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            '${r.folio} · Reportado el ${formatearFechaLarga(r.fechaCreacion)}',
            style: estiloMeta(context)?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
          ),
          if (detalle.descripcion.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(detalle.descripcion, style: estiloCuerpo(context, color: AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}

String textoPrioridad(Prioridad p) => switch (p) {
  Prioridad.alta => 'Prioridad alta',
  Prioridad.media => 'Prioridad media',
  Prioridad.baja => 'Prioridad baja',
};
