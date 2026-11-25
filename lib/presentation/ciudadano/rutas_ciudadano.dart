import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/rol.dart';
import '../../domain/repositories/avisos_repository.dart';
import '../avisos/avisos_del_rol.dart';
import '../avisos/avisos_screen.dart';
import '../avisos/avisos_viewmodel.dart';
import '../../domain/entities/incidencia_detalle.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/reportes_ciudadano_repository.dart';
import '../incidencia/ruta_detalle.dart';
import '../incidencia/vista_detalle.dart';
import '../routing/rutas.dart';
import 'ciudadano_shell.dart';
import 'mis_reportes/mis_reportes_screen.dart';
import 'mis_reportes/mis_reportes_viewmodel.dart';
import 'reabrir/reabrir_reporte_screen.dart';
import 'reabrir/reabrir_reporte_viewmodel.dart';

/// Rutas del ciudadano. Solo quien trabaja este rol toca este archivo.
List<RouteBase> rutasCiudadano() => [
  StatefulShellRoute.indexedStack(
    builder: (context, state, shell) => AvisosDelRol(
      rol: Rol.ciudadano,
      construirShell: (hayNoLeidos) => CiudadanoShell(shell: shell, avisosNoLeidos: hayNoLeidos),
    ),
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
            routes: [
              rutaDetalle(
                VistaDetalle.ciudadano,
                acciones: [
                  GoRoute(
                    path: 'reabrir',
                    // Sin la ficha cargada (deep link o hot restart) no hay nada que reabrir
                    redirect: (context, state) => state.extra is IncidenciaDetalle ? null : Rutas.homeCiudadano,
                    builder: (context, state) {
                      final detalle = state.extra! as IncidenciaDetalle;
                      return ChangeNotifierProvider(
                        create: (context) => ReabrirReporteViewModel(
                          id: detalle.resumen.id,
                          reportesRepository: context.read<ReportesCiudadanoRepository>(),
                        ),
                        child: ReabrirReporteScreen(detalle: detalle),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: Rutas.avisosCiudadano,
            builder: (context, state) => ChangeNotifierProvider(
              create: (context) => AvisosViewModel(avisosRepository: context.read<AvisosRepository>())..cargar(),
              child: const AvisosScreen(rol: Rol.ciudadano),
            ),
          ),
        ],
      ),
    ],
  ),
];
