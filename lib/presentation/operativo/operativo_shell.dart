import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';
import '../core/widgets/barra_inferior.dart';

/// Estructura del operativo: Asignadas · Mapa · Avisos.
class OperativoShell extends StatelessWidget {
  const OperativoShell({super.key, required this.shell, this.avisosNoLeidos = false});

  final StatefulNavigationShell shell;

  /// Punto naranja de 8 px sin número en la pestaña Avisos (design.md).
  final bool avisosNoLeidos;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: BarraInferior(
        shell: shell,
        destinos: [
          const NavigationDestination(icon: Icon(Icons.assignment_outlined), label: 'Asignadas'),
          const NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Mapa'),
          NavigationDestination(
            icon: Badge(
              key: const Key('punto_avisos'),
              isLabelVisible: avisosNoLeidos,
              smallSize: 8,
              backgroundColor: AppColors.accent,
              child: const Icon(Icons.notifications_outlined),
            ),
            label: 'Avisos',
          ),
        ],
      ),
    );
  }
}
