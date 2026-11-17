import 'package:flutter/material.dart';

import '../../core/result.dart';
import '../core/mensajes.dart';
import '../core/widgets/hoja_confirmacion.dart';

/// Diálogo de confirmación y snackbar para «Iniciar atención» en D1 y D2 (HU-15 / #46).
Future<void> confirmarInicioAtencion(
  BuildContext context,
  Future<Result<void>> Function() iniciar,
) async {
  final ok = await confirmarAccion(
    context,
    titulo: '¿Iniciar atención?',
    mensaje: 'La incidencia pasará a En proceso y el ciudadano podrá ver que ya la estás atendiendo.',
    accion: 'Iniciar atención',
  );
  if (!ok || !context.mounted) return;
  final res = await iniciar();
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        res is Error ? mensajePara(res.error) : 'Atención iniciada',
      ),
    ),
  );
}
