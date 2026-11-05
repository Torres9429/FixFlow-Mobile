import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/barra_inferior.dart';

/// Estructura del operativo: Asignadas · Mapa · Avisos.
class OperativoShell extends StatelessWidget {
  const OperativoShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: BarraInferior(
        shell: shell,
        destinos: const [
          NavigationDestination(icon: Icon(Icons.assignment_outlined), label: 'Asignadas'),
          NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Mapa'),
          NavigationDestination(icon: Icon(Icons.notifications_outlined), label: 'Avisos'),
        ],
      ),
    );
  }
}
