import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class CampoBloqueado extends StatelessWidget {
  const CampoBloqueado({super.key, required this.valor});

  final String valor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: AppColors.campoBloqueado,
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Text(
        valor,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
      ),
    );
  }
}
