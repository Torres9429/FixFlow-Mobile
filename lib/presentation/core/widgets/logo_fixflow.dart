import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Cuadro azul marino con la llave blanca (design.md §6).
class LogoFixFlow extends StatelessWidget {
  const LogoFixFlow({super.key, this.lado = 32, this.conSombra = false});

  final double lado;
  final bool conSombra;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: lado,
      height: lado,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(lado / 4),
        boxShadow: conSombra ? AppTheme.sombra : null,
      ),
      child: Icon(Icons.build_outlined, size: lado * 0.55, color: Colors.white),
    );
  }
}
