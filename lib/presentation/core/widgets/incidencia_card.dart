import 'package:flutter/material.dart';

import '../../../domain/entities/incidencia_resumen.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'estado_chip.dart';
import 'prioridad_simbolo.dart';

/// Tarjeta de incidencia de B1, D1, E1 y E2 (design.md §7). Toda la tarjeta abre el detalle.
class IncidenciaCard extends StatelessWidget {
  const IncidenciaCard({
    super.key,
    required this.incidencia,
    required this.meta,
    this.direccion,
    this.accion,
    this.onTap,
  });

  final IncidenciaResumen incidencia;

  /// «FX-2026-000142 · hoy, 11:30». Cada home la arma (D1 le agrega la distancia).
  final String meta;

  final String? direccion;

  /// Botón de la única acción válida para quien ve la tarjeta, si hay una.
  final Widget? accion;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final radio = BorderRadius.circular(AppTheme.radius);

    return DecoratedBox(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: radio, boxShadow: AppTheme.sombra),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: radio,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    EstadoChip(estado: incidencia.estado),
                    const Spacer(),
                    PrioridadSimbolo(prioridad: incidencia.prioridad),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Miniatura(url: incidencia.fotoUrl),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            incidencia.tipo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: texto.titleMedium?.copyWith(
                              fontSize: 16,
                              height: 22 / 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (direccion != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              direccion!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: texto.bodyLarge?.copyWith(
                                fontSize: 15,
                                height: 22 / 15,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            meta,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: texto.bodySmall?.copyWith(
                              fontSize: 13,
                              height: 18 / 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textMuted,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                          // El motivo solo se muestra si no es el del tipo (design.md §7)
                          if (!incidencia.motivoPrioridad.startsWith('Tipo de incidencia') &&
                              incidencia.motivoPrioridad.isNotEmpty)
                            Text(
                              incidencia.motivoPrioridad,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: texto.bodySmall?.copyWith(
                                fontSize: 13,
                                height: 18 / 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textMuted,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (accion != null) ...[const SizedBox(height: 16), accion!],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Miniatura extends StatelessWidget {
  const _Miniatura({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    const vacia = ColoredBox(color: AppColors.surfaceMuted, child: SizedBox.square(dimension: 64));

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: url == null
          ? vacia
          : Image.network(url!, width: 64, height: 64, fit: BoxFit.cover, errorBuilder: (_, _, _) => vacia),
    );
  }
}
