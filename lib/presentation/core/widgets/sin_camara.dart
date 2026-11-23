import 'package:flutter/material.dart';

import 'estado_vacio.dart';

/// B6: la cámara no se pudo abrir (sin permiso o sin cámara). La foto debe ser en vivo, sin galería (RN-09).
/// La usan la cámara del reporte (B3) y la de la solución (D3a).
class SinCamara extends StatelessWidget {
  const SinCamara({super.key, required this.onReintentar});

  final VoidCallback onReintentar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: EstadoVacio(
        icono: Icons.no_photography_outlined,
        titulo: 'No podemos usar la cámara',
        mensaje: 'La foto debe tomarse en este momento; no se puede elegir de la galería.',
        accion: 'Dar permiso',
        onAccion: onReintentar,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        ),
      ),
    );
  }
}
