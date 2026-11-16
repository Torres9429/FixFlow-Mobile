import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AvisoError extends StatelessWidget {
  const AvisoError({super.key, required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: AppColors.prioridadAltaBg, borderRadius: BorderRadius.circular(12)),
      child: Text(
        mensaje,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.error),
      ),
    );
  }
}
