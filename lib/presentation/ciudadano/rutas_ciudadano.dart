import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/reportes_ciudadano_repository.dart';
import '../core/widgets/pestana_pendiente.dart';
import '../routing/rutas.dart';
import 'ciudadano_shell.dart';
import 'mis_reportes/mis_reportes_screen.dart';
import 'mis_reportes/mis_reportes_viewmodel.dart';

/// Rutas del ciudadano. Solo quien trabaja este rol toca este archivo.
List<RouteBase> rutasCiudadano() => [
  StatefulShellRoute.indexedStack(
    builder: (context, state, shell) => CiudadanoShell(shell: shell),
    branches: [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: Rutas.homeCiudadano,
            builder: (context, state) => ChangeNotifierProvider(
              // B5 manda `?recargar=` al volver: un ViewModel nuevo trae el reporte recién enviado
              key: ValueKey(state.uri.queryParameters['recargar']),
              create: (context) => MisReportesViewModel(
                reportesRepository: context.read<ReportesCiudadanoRepository>(),
                authRepository: context.read<AuthRepository>(),
              )..iniciar(),
              child: const MisReportesScreen(),
            ),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: Rutas.avisosCiudadano,
            builder: (context, state) => const PestanaPendiente(titulo: 'Avisos', codigo: 'C1'),
          ),
        ],
      ),
    ],
  ),
];
