import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// «Hola, Ana» con una línea de apoyo debajo, al inicio de B1, D1 y E1.
class Saludo extends StatelessWidget {
  const Saludo({super.key, required this.nombre, required this.subtitulo});

  final String nombre;
  final String subtitulo;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nombre.isEmpty ? 'Hola' : 'Hola, $nombre',
            style: texto.headlineSmall?.copyWith(fontSize: 24, height: 30 / 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            subtitulo,
            style: texto.bodySmall?.copyWith(
              fontSize: 13,
              height: 18 / 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
