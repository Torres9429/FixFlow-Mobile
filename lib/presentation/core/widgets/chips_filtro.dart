import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Fila de chips con desplazamiento horizontal (B1, D1, E2). El primero suele ser «Todas».
class ChipsFiltro<T> extends StatelessWidget {
  const ChipsFiltro({super.key, required this.opciones, required this.seleccionada, required this.onSeleccionar});

  /// Valor y texto de cada chip, en orden. Usa `null` como valor de «Todas».
  final List<(T, String)> opciones;
  final T seleccionada;
  final ValueChanged<T> onSeleccionar;

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(context).textTheme.labelMedium?.copyWith(fontSize: 12, fontWeight: FontWeight.w600);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          for (final (i, (valor, texto)) in opciones.indexed) ...[
            if (i > 0) const SizedBox(width: 8),
            _Chip(texto: texto, activo: valor == seleccionada, estilo: estilo, onTap: () => onSeleccionar(valor)),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.texto, required this.activo, required this.estilo, required this.onTap});

  final String texto;
  final bool activo;
  final TextStyle? estilo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radio = BorderRadius.circular(999);

    return Material(
      color: activo ? AppColors.primary : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radio,
        side: activo ? BorderSide.none : const BorderSide(color: AppColors.borderSubtle),
      ),
      child: InkWell(
        borderRadius: radio,
        onTap: onTap,
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          child: Text(texto, style: estilo?.copyWith(color: activo ? Colors.white : AppColors.textSecondary)),
        ),
      ),
    );
  }
}
