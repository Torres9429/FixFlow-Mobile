import 'package:flutter/material.dart';

/// Acciones de una pantalla (detalle, D3): van **al final del contenido**, después de la última sección,
/// y se desplazan con él; no quedan fijas abajo. Un botón primario y, si aplica, uno secundario.
/// Si no hay acción válida, no se pone.
class BarraAcciones extends StatelessWidget {
  const BarraAcciones({super.key, required this.primario, this.secundario});

  final Widget primario;
  final Widget? secundario;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          primario,
          if (secundario != null) ...[const SizedBox(height: 12), secundario!],
        ],
      ),
    );
  }
}
