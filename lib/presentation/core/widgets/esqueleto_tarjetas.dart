import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Primera carga de una lista: 3 tarjetas grises (design.md §7).
class EsqueletoTarjetas extends StatelessWidget {
  const EsqueletoTarjetas({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < 3; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppTheme.radius),
            ),
          ),
        ],
      ],
    );
  }
}
