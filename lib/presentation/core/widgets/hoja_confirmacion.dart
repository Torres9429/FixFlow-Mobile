import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Abre una hoja inferior blanca con el estilo de los diálogos de la app (design.md, «Diálogos de confirmación»).
Future<T?> mostrarHoja<T>(BuildContext context, {required WidgetBuilder builder, bool descartable = true}) =>
    showModalBottomSheet<T>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      isDismissible: descartable,
      enableDrag: descartable,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: builder,
    );

/// Confirmación (A3c, E8a, E12a…): título, una línea de explicación, un [detalle] opcional,
/// la acción (en rojo si es [destructiva]) y «Cancelar» como texto. Devuelve `true` si se confirma.
Future<bool> confirmarAccion(
  BuildContext context, {
  required String titulo,
  required String mensaje,
  required String accion,
  bool destructiva = false,
  Widget? detalle,
  Key? claveConfirmar,
  Key? claveCancelar,
}) async {
  final confirmado = await mostrarHoja<bool>(
    context,
    builder: (hojaContext) => ContenidoHoja(
      titulo: titulo,
      mensaje: mensaje,
      detalle: detalle,
      acciones: [
        FilledButton(
          key: claveConfirmar,
          style: destructiva ? FilledButton.styleFrom(backgroundColor: AppColors.error) : null,
          onPressed: () => Navigator.of(hojaContext).pop(true),
          child: Text(accion),
        ),
        const SizedBox(height: 8),
        TextButton(
          key: claveCancelar,
          onPressed: () => Navigator.of(hojaContext).pop(false),
          child: const Text('Cancelar'),
        ),
      ],
    ),
  );
  return confirmado ?? false;
}

/// Cuerpo común de las hojas: título en 17/700, texto secundario, detalle opcional y los botones.
class ContenidoHoja extends StatelessWidget {
  const ContenidoHoja({super.key, required this.titulo, required this.mensaje, required this.acciones, this.detalle});

  final String titulo;
  final String mensaje;
  final Widget? detalle;
  final List<Widget> acciones;

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
            Text(titulo, style: texto.titleMedium?.copyWith(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              mensaje,
              style: texto.bodyMedium?.copyWith(fontSize: 15, height: 22 / 15, color: AppColors.textSecondary),
            ),
            if (detalle case final d?) ...[const SizedBox(height: 16), d],
            const SizedBox(height: 24),
            ...acciones,
          ],
        ),
      ),
    );
  }
}

/// Recuadro gris con pares etiqueta–valor, para el [detalle] de una hoja.
/// La etiqueta va arriba y el valor abajo, así un valor largo (un correo, una contraseña) no se encima.
class DatosHoja extends StatelessWidget {
  const DatosHoja({super.key, required this.datos});

  final List<(String, String)> datos;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, (etiqueta, valor)) in datos.indexed) ...[
            if (i > 0) const SizedBox(height: 14),
            Text(etiqueta, style: texto.bodySmall?.copyWith(fontSize: 13, color: AppColors.textMuted)),
            const SizedBox(height: 2),
            SelectableText(
              valor,
              style: texto.bodyLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
          ],
        ],
      ),
    );
  }
}
