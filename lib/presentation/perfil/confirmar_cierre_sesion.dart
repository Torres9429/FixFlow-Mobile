import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

Future<bool> confirmarCierreSesion(BuildContext context) async {
  final confirmado = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) => const _HojaCierreSesion(),
  );
  return confirmado ?? false;
}

class _HojaCierreSesion extends StatelessWidget {
  const _HojaCierreSesion();

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('¿Cerrar sesión?', style: texto.titleMedium?.copyWith(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'Tendrás que escribir tu correo y contraseña para volver a entrar.',
              style: texto.bodyMedium?.copyWith(fontSize: 15, height: 22 / 15, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('confirmar_cerrar_sesion'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Cerrar sesión'),
            ),
            const SizedBox(height: 8),
            TextButton(
              key: const Key('cancelar_cerrar_sesion'),
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}
