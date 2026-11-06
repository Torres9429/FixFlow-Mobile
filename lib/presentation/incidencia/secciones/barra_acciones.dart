import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Barra de acciones del detalle (design.md §7): fija abajo, fondo blanco, borde superior y 16 de padding.
/// Lleva un botón primario y, si aplica, uno secundario con contorno. Si no hay acción válida, no se pone.
class BarraAcciones extends StatelessWidget {
  const BarraAcciones({super.key, required this.primario, this.secundario});

  final Widget primario;
  final Widget? secundario;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              primario,
              if (secundario != null) ...[const SizedBox(height: 12), secundario!],
            ],
          ),
        ),
      ),
    );
  }
}
