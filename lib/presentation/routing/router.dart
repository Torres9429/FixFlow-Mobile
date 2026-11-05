import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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
import '../reporte/enviado/reporte_enviado_screen.dart';
import '../reporte/nuevo_reporte_screen.dart';
import 'rutas.dart';

GoRouter crearRouter() => GoRouter(
  initialLocation: Rutas.login,
  routes: [
    GoRoute(
      path: Rutas.login,
      builder: (context, state) {
        final cuentaCreada = state.uri.queryParameters['cuentaCreada'] == 'true';
        return ChangeNotifierProvider(
          create: (context) => LoginViewModel(authRepository: context.read<AuthRepository>()),
          child: LoginScreen(cuentaCreada: cuentaCreada),
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
    GoRoute(path: Rutas.perfil, builder: (context, state) => const PerfilScreen()),
  ],
);
