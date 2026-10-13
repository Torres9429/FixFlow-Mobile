import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../domain/repositories/auth_repository.dart';
import '../auth/login/login_screen.dart';
import '../auth/login/login_viewmodel.dart';
import '../home/home_admin_screen.dart';
import '../home/home_ciudadano_screen.dart';
import '../home/home_operativo_screen.dart';
import 'rutas.dart';

GoRouter crearRouter() => GoRouter(
      initialLocation: Rutas.login,
      routes: [
        GoRoute(
          path: Rutas.login,
          builder: (context, state) => ChangeNotifierProvider(
            create: (context) => LoginViewModel(authRepository: context.read<AuthRepository>()),
            child: const LoginScreen(),
          ),
        ),
        GoRoute(path: Rutas.homeCiudadano, builder: (context, state) => const HomeCiudadanoScreen()),
        GoRoute(path: Rutas.homeOperativo, builder: (context, state) => const HomeOperativoScreen()),
        GoRoute(path: Rutas.homeAdmin, builder: (context, state) => const HomeAdminScreen()),
      ],
    );
