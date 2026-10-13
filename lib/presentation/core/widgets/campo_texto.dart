import 'package:flutter/material.dart';

/// Etiqueta arriba del campo, como en el diseño (no la etiqueta flotante de Material).
class CampoTexto extends StatelessWidget {
  const CampoTexto({super.key, required this.etiqueta, required this.child});

  final String etiqueta;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          etiqueta,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
