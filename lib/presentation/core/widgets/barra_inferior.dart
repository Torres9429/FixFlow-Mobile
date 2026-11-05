import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Barra de pestañas del operativo y del admin. El ciudadano usa la suya, con el botón Reportar.
class BarraInferior extends StatelessWidget {
  const BarraInferior({super.key, required this.shell, required this.destinos});

  final StatefulNavigationShell shell;
  final List<NavigationDestination> destinos;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.surface, boxShadow: AppTheme.sombraBarraInferior),
      child: NavigationBar(
        height: AppTheme.alturaBarraInferior,
        elevation: 0,
        selectedIndex: shell.currentIndex,
        // Tocar la pestaña activa regresa a su pantalla inicial
        onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: destinos,
      ),
    );
  }
}
