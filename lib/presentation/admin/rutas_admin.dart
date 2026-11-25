import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/rol.dart';
import '../../domain/repositories/avisos_repository.dart';
import '../avisos/avisos_del_rol.dart';
import '../avisos/avisos_screen.dart';
import '../avisos/avisos_viewmodel.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/tipo_incidencia.dart';
import '../../domain/repositories/direccion_repository.dart';
import '../../domain/repositories/incidence_type_repository.dart';
import '../../domain/repositories/incidencias_repository.dart';
import '../incidencia/ruta_detalle.dart';
import '../incidencia/vista_detalle.dart';
import '../perfil/perfil_screen.dart';
import '../perfil/perfil_viewmodel.dart';
import '../routing/rutas.dart';
import 'admin_shell.dart';
import 'catalogo/catalogo_tipos_screen.dart';
import 'catalogo/catalogo_tipos_viewmodel.dart';
import 'catalogo/tipo_form_screen.dart';
import 'catalogo/tipo_form_viewmodel.dart';
import 'panel/panel_screen.dart';
import 'panel/panel_viewmodel.dart';
import 'asignacion/asignacion_screen.dart';
import 'asignacion/asignacion_viewmodel.dart';
import 'incidencias/incidencias_admin_screen.dart';
import 'incidencias/incidencias_admin_viewmodel.dart';
import 'personal/alta_operativo_screen.dart';
import 'personal/alta_operativo_viewmodel.dart';
import 'personal/personal_screen.dart';
import 'personal/personal_viewmodel.dart';

/// Rutas del admin. Solo quien trabaja este rol toca este archivo.
List<RouteBase> rutasAdmin() => [
  StatefulShellRoute.indexedStack(
    builder: (context, state, shell) => AvisosDelRol(
      rol: Rol.admin,
      // El admin no tiene pestaña de avisos: el punto va en la campana (CampanaAvisos)
      construirShell: (_) => AdminShell(shell: shell),
    ),
    branches: [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: Rutas.homeAdmin,
            builder: (context, state) => ChangeNotifierProvider(
              create: (context) => PanelViewModel(
                adminRepository: context.read<AdminRepository>(),
                authRepository: context.read<AuthRepository>(),
                tiposRepository: context.read<IncidenceTypeRepository>(),
              )..iniciar(),
              child: const PanelScreen(),
            ),
            routes: [
              rutaDetalle(
                VistaDetalle.admin,
                acciones: [
                  // E5 lo construye la tarjeta «Asignar y reasignar»; aquí solo se reemplaza el builder
                  GoRoute(
                    path: 'asignar',
                    builder: (context, state) => ChangeNotifierProvider(
                      create: (context) => AsignacionViewModel(
                        id: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
                        adminRepository: context.read<AdminRepository>(),
                        direccionRepository: context
                            .read<DireccionRepository>(),
                        incidenciasRepository: context
                            .read<IncidenciasRepository>(),
                      )..iniciar(),
                      child: const AsignacionScreen(),
                    ),
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
            path: Rutas.personal,
            builder: (context, state) => ChangeNotifierProvider(
              create: (context) =>
                  PersonalViewModel(adminRepository: context.read<AdminRepository>())..iniciar(),
              child: const PersonalScreen(),
            ),
            routes: [
              GoRoute(
                path: 'nuevo',
                builder: (context, state) => ChangeNotifierProvider(
                  create: (context) =>
                      AltaOperativoViewModel(adminRepository: context.read<AdminRepository>()),
                  child: const AltaOperativoScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: Rutas.incidenciasAdmin,
            builder: (context, state) => ChangeNotifierProvider(
              create: (context) => IncidenciasAdminViewModel(
                adminRepository: context.read<AdminRepository>(),
                tiposRepository: context.read<IncidenceTypeRepository>(),
              )..iniciar(),
              child: const IncidenciasAdminScreen(),
            ),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: Rutas.perfilAdmin,
            builder: (context, state) => ChangeNotifierProvider(
              create: (context) => PerfilViewModel(authRepository: context.read<AuthRepository>())..cargar(),
              child: const PerfilScreen(comoPestana: true),
            ),
          ),
        ],
      ),
    ],
  ),
  // La campana abre los avisos encima de las pestañas
  GoRoute(
    path: Rutas.avisosAdmin,
    builder: (context, state) => ChangeNotifierProvider(
      create: (context) => AvisosViewModel(avisosRepository: context.read<AvisosRepository>())..cargar(),
      child: const AvisosScreen(rol: Rol.admin),
    ),
  ),
  // E10 → E11 o E12, sin barra inferior (design.md)
  GoRoute(
    path: Rutas.catalogoTipos,
    builder: (context, state) => ChangeNotifierProvider(
      create: (context) =>
          CatalogoTiposViewModel(tiposRepository: context.read<IncidenceTypeRepository>())..cargar(),
      child: const CatalogoTiposScreen(),
    ),
    routes: [
      GoRoute(
        path: 'nuevo',
        builder: (context, state) => ChangeNotifierProvider(
          create: (context) => TipoFormViewModel(tiposRepository: context.read<IncidenceTypeRepository>()),
          child: const TipoFormScreen(),
        ),
      ),
      GoRoute(
        path: 'editar',
        // Sin el tipo (por ejemplo, tras reiniciar la app) se regresa al catálogo
        redirect: (context, state) => state.extra is TipoIncidencia ? null : Rutas.catalogoTipos,
        builder: (context, state) => ChangeNotifierProvider(
          create: (context) => TipoFormViewModel(
            tiposRepository: context.read<IncidenceTypeRepository>(),
            tipo: state.extra! as TipoIncidencia,
          ),
          child: const TipoFormScreen(),
        ),
      ),
    ],
  ),
];
