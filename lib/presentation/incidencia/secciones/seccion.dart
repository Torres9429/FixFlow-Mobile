import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Título de una sección del detalle («Ubicación», «Fotos de evidencia»), con un dato opcional a la derecha.
class TituloSeccion extends StatelessWidget {
  const TituloSeccion(this.titulo, {super.key, this.dato});

  final String titulo;
  final String? dato;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text(
              titulo,
              style: texto.titleMedium?.copyWith(fontSize: 17, height: 24 / 17, fontWeight: FontWeight.w700),
            ),
          ),
          if (dato != null) Text(dato!, style: estiloMeta(context)),
        ],
      ),
    );
  }
}

/// Fondo gris redondeado de cada sección.
class BloqueSeccion extends StatelessWidget {
  const BloqueSeccion({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppTheme.radius)),
      child: Padding(padding: padding, child: child),
    );
  }
}

/// Texto de cuerpo (15) del detalle.
TextStyle? estiloCuerpo(BuildContext context, {Color color = AppColors.textPrimary}) =>
    Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 15, height: 22 / 15, color: color);

/// Fechas, folios y quién hizo algo (13/500).
TextStyle? estiloMeta(BuildContext context) => Theme.of(context).textTheme.bodySmall?.copyWith(
  fontSize: 13,
  height: 18 / 13,
  fontWeight: FontWeight.w500,
  color: AppColors.textMuted,
);
