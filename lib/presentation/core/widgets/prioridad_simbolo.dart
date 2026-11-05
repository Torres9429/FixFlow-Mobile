import 'package:flutter/material.dart';

import '../../../domain/entities/prioridad.dart';
import '../theme/app_colors.dart';

/// Prioridad como 3 barras verticales, nunca como píldora (design.md §7).
/// Alta: 3 llenas · Media: 2 · Baja: 1; el color cambia con la prioridad.
class PrioridadSimbolo extends StatelessWidget {
  const PrioridadSimbolo({super.key, required this.prioridad});

  final Prioridad prioridad;

  static const _altos = [6.0, 10.0, 14.0];

  @override
  Widget build(BuildContext context) {
    final (llenas, color, etiqueta) = switch (prioridad) {
      Prioridad.alta => (3, AppColors.prioridadAlta, 'Prioridad alta'),
      Prioridad.media => (2, AppColors.prioridadMedia, 'Prioridad media'),
      Prioridad.baja => (1, AppColors.prioridadBaja, 'Prioridad baja'),
    };

    return Semantics(
      label: etiqueta,
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < _altos.length; i++) ...[
              if (i > 0) const SizedBox(width: 2),
              Container(
                width: 4,
                height: _altos[i],
                decoration: BoxDecoration(
                  color: i < llenas ? color : AppColors.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
