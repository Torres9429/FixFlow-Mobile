import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../domain/repositories/admin_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../core/widgets/pestana_pendiente.dart';
import '../incidencia/ruta_detalle.dart';
import '../incidencia/vista_detalle.dart';
import '../perfil/perfil_screen.dart';
import '../routing/rutas.dart';
import 'admin_shell.dart';
import 'panel/panel_screen.dart';
import 'panel/panel_viewmodel.dart';

/// Rutas del admin. Solo quien trabaja este rol toca este archivo.
List<RouteBase> rutasAdmin() => [
  StatefulShellRoute.indexedStack(
    builder: (context, state, shell) => AdminShell(shell: shell),
    branches: [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: Rutas.homeAdmin,
            builder: (context, state) => ChangeNotifierProvider(
              create: (context) => PanelViewModel(
                adminRepository: context.read<AdminRepository>(),
                authRepository: context.read<AuthRepository>(),
              )..iniciar(),
              child: const PanelScreen(),
            ),
            routes: [rutaDetalle(VistaDetalle.admin)],
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: Rutas.personal,
            builder: (context, state) => const PestanaPendiente(titulo: 'Personal', codigo: 'E8'),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: Rutas.incidenciasAdmin,
            builder: (context, state) => const PestanaPendiente(titulo: 'Incidencias', codigo: 'E2'),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [GoRoute(path: Rutas.perfilAdmin, builder: (context, state) => const PerfilScreen())],
      ),
    ],
  ),
  // La campana abre los avisos encima de las pestañas
  GoRoute(
    path: Rutas.avisosAdmin,
    builder: (context, state) => const PestanaPendiente(titulo: 'Avisos', codigo: 'E7'),
  ),
];
