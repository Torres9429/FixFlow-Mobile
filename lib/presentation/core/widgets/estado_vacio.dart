import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Pantalla de estado (C4, sin conexión, sin resultados): icono en un círculo, título, texto y una acción opcional.
class EstadoVacio extends StatelessWidget {
  const EstadoVacio({
    super.key,
    required this.icono,
    required this.titulo,
    required this.mensaje,
    this.accion,
    this.onAccion,
  });

  /// Una consulta falló: el [mensaje] viene de `mensajePara` y el botón reintenta.
  const EstadoVacio.error({super.key, required this.mensaje, required VoidCallback onReintentar})
    : icono = Icons.cloud_off_outlined,
      titulo = 'No se pudo cargar',
      accion = 'Reintentar',
      onAccion = onReintentar;

  final IconData icono;
  final String titulo;
  final String mensaje;

  /// Texto del botón; sin él no hay botón.
  final String? accion;
  final VoidCallback? onAccion;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 480),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(color: AppColors.primaryContainer, shape: BoxShape.circle),
              child: Icon(icono, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Column(
                children: [
                  Text(
                    titulo,
                    textAlign: TextAlign.center,
                    style: texto.titleLarge?.copyWith(fontSize: 20, height: 26 / 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mensaje,
                    textAlign: TextAlign.center,
                    style: texto.bodyLarge?.copyWith(fontSize: 15, height: 22 / 15, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            if (accion != null) ...[
              const SizedBox(height: 32),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(onPressed: onAccion, child: Text(accion!)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
