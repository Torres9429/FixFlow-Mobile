import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'logo_fixflow.dart';

/// Barra superior de las pantallas principales (B1, D1, E1): logo + «FixFlow» y,
/// a la derecha, el botón de perfil (ciudadano y operativo) o la campana (admin).
class BarraPrincipal extends StatelessWidget implements PreferredSizeWidget {
  const BarraPrincipal({super.key, required this.accion});

  /// Normalmente un [BotonCircular].
  final Widget accion;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 64,
      titleSpacing: 20,
      title: Row(
        children: [
          const LogoFixFlow(lado: 36),
          const SizedBox(width: 8),
          Text(
            'FixFlow',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontSize: 17, height: 24 / 17, fontWeight: FontWeight.w700, letterSpacing: -0.2),
          ),
        ],
      ),
      actions: [Padding(padding: const EdgeInsets.only(right: 20), child: accion)],
    );
  }
}

/// Círculo de 40 con borde para perfil o avisos. Con [conPunto] lleva el punto naranja de no leídos.
class BotonCircular extends StatelessWidget {
  const BotonCircular({
    super.key,
    required this.icono,
    required this.etiqueta,
    required this.onPressed,
    this.conPunto = false,
  });

  final IconData icono;
  final String etiqueta;
  final VoidCallback onPressed;
  final bool conPunto;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: etiqueta,
      child: Material(
        color: AppColors.surface,
        shape: const CircleBorder(side: BorderSide(color: AppColors.borderSubtle)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox.square(
            dimension: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(icono, size: 20, color: AppColors.textSecondary),
                if (conPunto)
                  Positioned(
                    top: 9,
                    right: 9,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
