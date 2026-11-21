import 'package:flutter/material.dart';

import '../../core/result.dart';
import '../core/mensajes.dart';
import '../core/widgets/hoja_confirmacion.dart';

/// Diálogo de confirmación y snackbar para «Confirmar resolución» en C2 (HU-13 / #71).
/// El snackbar muestra el texto del servidor (regla 5).
Future<void> confirmarResolucion(
  BuildContext context,
  Future<Result<String>> Function() confirmar,
) async {
  final ok = await confirmarAccion(
    context,
    titulo: '¿Confirmar resolución?',
    mensaje: 'Tu reporte quedará Cerrado y ya no podrás reabrirlo.',
    accion: 'Confirmar resolución',
  );
  if (!ok || !context.mounted) return;
  final res = await confirmar();
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(switch (res) {
        Ok(:final value) => value,
        Error(:final error) => mensajePara(error),
      }),
    ),
  );
}
