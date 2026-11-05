import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Pestaña que todavía no se construye. La reemplaza la tarjeta de su pantalla.
class PestanaPendiente extends StatelessWidget {
  const PestanaPendiente({super.key, required this.titulo, required this.codigo, this.barra});

  final String titulo;

  /// Código del lienzo, por ejemplo «B1».
  final String codigo;

  /// Si es una pantalla principal, la [BarraPrincipal]; si no, una barra con el título.
  final PreferredSizeWidget? barra;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: barra ?? AppBar(title: Text(titulo)),
      body: Center(
        child: Text(
          '$titulo ($codigo)',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
        ),
      ),
    );
  }
}
