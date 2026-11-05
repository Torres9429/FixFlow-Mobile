import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/barra_inferior.dart';

/// Estructura del admin: Inicio · Personal · Incidencias · Perfil. Los avisos se abren con la campana.
class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: BarraInferior(
        shell: shell,
        destinos: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.group_outlined), label: 'Personal'),
          NavigationDestination(icon: Icon(Icons.assignment_outlined), label: 'Incidencias'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }
}
