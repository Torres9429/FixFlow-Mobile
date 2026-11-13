import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/sesion/sesion_expirada.dart';
import '../../domain/entities/reporte_creado.dart';
import '../../domain/repositories/auth_repository.dart';
import '../admin/rutas_admin.dart';
import '../auth/login/login_screen.dart';
import '../auth/login/login_viewmodel.dart';
import '../auth/registro/registro_screen.dart';
import '../auth/registro/registro_viewmodel.dart';
import '../ciudadano/rutas_ciudadano.dart';
import '../operativo/rutas_operativo.dart';
import '../perfil/perfil_screen.dart';
import '../perfil/perfil_viewmodel.dart';
import '../reporte/enviado/reporte_enviado_screen.dart';
import '../reporte/nuevo_reporte_screen.dart';
import 'rutas.dart';

/// [sesionExpirada] es el estado de la sesión: cuando cambia, el router vuelve a evaluar [GoRouter.redirect]
/// y, si venció, manda al login (RNF-09). Sin él (en las pruebas) no se redirige.
GoRouter crearRouter({SesionExpirada? sesionExpirada}) => GoRouter(
  initialLocation: Rutas.login,
  refreshListenable: sesionExpirada,
  redirect: (context, state) => (sesionExpirada?.consumirAviso() ?? false) ? '${Rutas.login}?sesionVencida=true' : null,
  routes: [
    GoRoute(
      path: Rutas.login,
      builder: (context, state) {
        final parametros = state.uri.queryParameters;
        return ChangeNotifierProvider(
          create: (context) => LoginViewModel(authRepository: context.read<AuthRepository>()),
          child: LoginScreen(
            cuentaCreada: parametros['cuentaCreada'] == 'true',
            sesionVencida: parametros['sesionVencida'] == 'true',
          ),
        );
      },
    ),
    GoRoute(
      path: Rutas.registro,
      builder: (context, state) => ChangeNotifierProvider(
        create: (context) => RegistroViewModel(authRepository: context.read<AuthRepository>()),
        child: const RegistroScreen(),
      ),
    ),
    // Cada rol vive en su propio archivo de rutas
    ...rutasCiudadano(),
    ...rutasOperativo(),
    ...rutasAdmin(),
    // Pantallas que se abren encima de las pestañas
    GoRoute(path: Rutas.nuevoReporte, builder: (context, state) => const NuevoReporteScreen()),
    GoRoute(
      path: Rutas.reporteEnviado,
      // Sin el reporte (por ejemplo, tras un hot restart) no hay nada que mostrar
      redirect: (context, state) => state.extra is ReporteCreado ? null : Rutas.homeCiudadano,
      builder: (context, state) => ReporteEnviadoScreen(reporte: state.extra! as ReporteCreado),
    ),
    GoRoute(
      path: Rutas.perfil,
      builder: (context, state) => ChangeNotifierProvider(
        create: (context) => PerfilViewModel(authRepository: context.read<AuthRepository>())..cargar(),
        child: const PerfilScreen(),
      ),
    ),
  ],
);
