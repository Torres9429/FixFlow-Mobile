import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'home_base.dart';
import '../routing/rutas.dart';

class HomeCiudadanoScreen extends StatelessWidget {
  const HomeCiudadanoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeBase(
      titulo: 'Inicio · Ciudadano',
      descripcion: 'Aquí irán tus reportes (HU-10).',
      acciones: [
        FilledButton.icon(
          key: const Key('crear_reporte'),
          onPressed: () => context.push(Rutas.nuevoReporte),
          icon: const Icon(Icons.add_a_photo_outlined),
          label: const Text('Nuevo reporte'),
        ),
      ],
    );
  }
}
