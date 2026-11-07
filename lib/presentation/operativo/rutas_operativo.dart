import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/operativo_repository.dart';
import '../../domain/repositories/ubicacion_repository.dart';
import '../core/widgets/pestana_pendiente.dart';
import '../incidencia/ruta_detalle.dart';
import '../incidencia/vista_detalle.dart';
import '../routing/rutas.dart';
import 'asignadas/asignadas_screen.dart';
import 'asignadas/asignadas_viewmodel.dart';
import 'operativo_shell.dart';

/// Rutas del operativo. Solo quien trabaja este rol toca este archivo.
List<RouteBase> rutasOperativo() => [
  StatefulShellRoute.indexedStack(
    builder: (context, state, shell) => OperativoShell(shell: shell),
    branches: [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: Rutas.homeOperativo,
            builder: (context, state) => ChangeNotifierProvider(
              create: (context) => AsignadasViewModel(
                operativoRepository: context.read<OperativoRepository>(),
                ubicacionRepository: context.read<UbicacionRepository>(),
                authRepository: context.read<AuthRepository>(),
              )..iniciar(),
              child: const AsignadasScreen(),
            ),
            routes: [rutaDetalle(VistaDetalle.operativo)],
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: Rutas.mapaOperativo,
            builder: (context, state) => const PestanaPendiente(titulo: 'Mapa', codigo: 'D5'),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: Rutas.avisosOperativo,
            builder: (context, state) => const PestanaPendiente(titulo: 'Avisos', codigo: 'D6'),
          ),
        ],
      ),
    ],
  ),
];
