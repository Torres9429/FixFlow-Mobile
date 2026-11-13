import 'package:fix_flow/core/result.dart';
import 'package:fix_flow/domain/entities/perfil.dart';
import 'package:fix_flow/domain/entities/rol.dart';
import 'package:fix_flow/domain/errors/falla_red.dart';
import 'package:fix_flow/presentation/core/theme/app_theme.dart';
import 'package:fix_flow/presentation/perfil/cambiar_password/cambiar_password_screen.dart';
import 'package:fix_flow/presentation/perfil/cambiar_password/cambiar_password_viewmodel.dart';
import 'package:fix_flow/presentation/perfil/editar_datos/editar_datos_screen.dart';
import 'package:fix_flow/presentation/perfil/editar_datos/editar_datos_viewmodel.dart';
import 'package:fix_flow/presentation/perfil/perfil_screen.dart';
import 'package:fix_flow/presentation/perfil/perfil_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import '../mocks.dart';

const _perfil = Perfil(
  id: 1,
  nombre: 'Mariana',
  apellidos: 'García Ruiz',
  correo: 'mariana.garcia@correo.com',
  rol: Rol.ciudadano,
);

Widget _appPerfil(MockAuthRepository repo) => MaterialApp.router(
  theme: AppTheme.light,
  routerConfig: GoRouter(
    initialLocation: '/inicio',
    routes: [
      GoRoute(
        path: '/inicio',
        builder: (context, state) => Scaffold(
          body: TextButton(onPressed: () => context.push('/perfil'), child: const Text('abrir')),
        ),
      ),
      GoRoute(
        path: '/perfil',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => PerfilViewModel(authRepository: repo)..cargar(),
          child: const PerfilScreen(),
        ),
      ),
      GoRoute(path: '/login', builder: (context, state) => const Scaffold(body: Text('pantalla de login'))),
    ],
  ),
);

Object? _resultado;

Future<void> _abrirPantalla(WidgetTester tester, Widget pantalla) async {
  _resultado = null;
  await tester.pumpWidget(
    MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: GoRouter(
        initialLocation: '/inicio',
        routes: [
          GoRoute(
            path: '/inicio',
            builder: (context, state) => Scaffold(
              body: TextButton(
                onPressed: () async => _resultado = await context.push<Object>('/pantalla'),
                child: const Text('abrir'),
              ),
            ),
          ),
          GoRoute(path: '/pantalla', builder: (context, state) => pantalla),
        ],
      ),
    ),
  );
  await tester.tap(find.text('abrir'));
  await tester.pumpAndSettle();
}

Future<void> _abrirPerfil(WidgetTester tester, MockAuthRepository repo) async {
  await tester.pumpWidget(_appPerfil(repo));
  await tester.tap(find.text('abrir'));
  await tester.pumpAndSettle();
}

void main() {
  group('HU-25: A3 Perfil', () {
    testWidgets('Muestra iniciales, nombre completo, correo y rol', (tester) async {
      final repo = MockAuthRepository();
      when(repo.miPerfil).thenAnswer((_) async => const Result.ok(_perfil));

      await _abrirPerfil(tester, repo);

      expect(find.text('MG'), findsOneWidget);
      expect(find.text('Mariana García Ruiz'), findsOneWidget);
      expect(find.text('mariana.garcia@correo.com'), findsOneWidget);
      expect(find.text('Ciudadano'), findsOneWidget);
      expect(find.text('Editar mis datos'), findsOneWidget);
      expect(find.text('Cambiar contraseña'), findsOneWidget);
    });

    testWidgets('Si falla la consulta muestra el error y Reintentar', (tester) async {
      final repo = MockAuthRepository();
      when(repo.miPerfil).thenAnswer((_) async => const Result.error(SinConexion()));

      await _abrirPerfil(tester, repo);

      expect(find.text('No se pudo cargar'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
    });
  });

  group('HU-02: A3c Confirmar cierre de sesión', () {
    testWidgets('Cancelar cierra el diálogo y la sesión sigue', (tester) async {
      final repo = MockAuthRepository();
      when(repo.miPerfil).thenAnswer((_) async => const Result.ok(_perfil));

      await _abrirPerfil(tester, repo);
      await tester.ensureVisible(find.byKey(const Key('cerrar_sesion')));
      await tester.tap(find.byKey(const Key('cerrar_sesion')));
      await tester.pumpAndSettle();

      expect(find.text('¿Cerrar sesión?'), findsOneWidget);

      await tester.tap(find.byKey(const Key('cancelar_cerrar_sesion')));
      await tester.pumpAndSettle();

      expect(find.text('¿Cerrar sesión?'), findsNothing);
      expect(find.byType(PerfilScreen), findsOneWidget);
      verifyNever(repo.cerrarSesion);
    });

    testWidgets('Confirmar cierra la sesión y regresa al login', (tester) async {
      final repo = MockAuthRepository();
      when(repo.miPerfil).thenAnswer((_) async => const Result.ok(_perfil));
      when(repo.cerrarSesion).thenAnswer((_) async {});

      await _abrirPerfil(tester, repo);
      await tester.ensureVisible(find.byKey(const Key('cerrar_sesion')));
      await tester.tap(find.byKey(const Key('cerrar_sesion')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirmar_cerrar_sesion')));
      await tester.pumpAndSettle();

      verify(repo.cerrarSesion).called(1);
      expect(find.text('pantalla de login'), findsOneWidget);
    });
  });

  group('HU-25: A3a Editar mis datos', () {
    Widget pantalla(MockAuthRepository repo) => ChangeNotifierProvider(
      create: (_) => EditarDatosViewModel(authRepository: repo, perfil: _perfil),
      child: const EditarDatosScreen(),
    );

    testWidgets('El correo y el rol se muestran pero no se pueden editar', (tester) async {
      await _abrirPantalla(tester, pantalla(MockAuthRepository()));

      expect(find.text('mariana.garcia@correo.com'), findsOneWidget);
      expect(find.text('Ciudadano'), findsOneWidget);
      expect(find.descendant(of: find.byKey(const Key('editar_correo')), matching: find.byType(TextField)), findsNothing);
      expect(find.descendant(of: find.byKey(const Key('editar_rol')), matching: find.byType(TextField)), findsNothing);
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('Con el nombre vacío no se guarda', (tester) async {
      final repo = MockAuthRepository();
      await _abrirPantalla(tester, pantalla(repo));

      await tester.enterText(find.byKey(const Key('editar_nombre')), '');
      await tester.ensureVisible(find.byKey(const Key('editar_guardar')));
      await tester.tap(find.byKey(const Key('editar_guardar')));
      await tester.pumpAndSettle();

      expect(find.text('Campo obligatorio'), findsOneWidget);
      verifyNever(
        () => repo.actualizarPerfil(nombre: any(named: 'nombre'), apellidos: any(named: 'apellidos')),
      );
    });

    testWidgets('Guardar manda el nombre y los apellidos sin espacios de más', (tester) async {
      final repo = MockAuthRepository();
      when(() => repo.actualizarPerfil(nombre: any(named: 'nombre'), apellidos: any(named: 'apellidos')))
          .thenAnswer((_) async => const Result.ok(_perfil));
      await _abrirPantalla(tester, pantalla(repo));

      await tester.enterText(find.byKey(const Key('editar_nombre')), '  Mariana Isabel ');
      await tester.ensureVisible(find.byKey(const Key('editar_guardar')));
      await tester.tap(find.byKey(const Key('editar_guardar')));
      await tester.pumpAndSettle();

      verify(() => repo.actualizarPerfil(nombre: 'Mariana Isabel', apellidos: 'García Ruiz')).called(1);
      expect(find.byType(EditarDatosScreen), findsNothing);
      expect(_resultado, _perfil);
    });
  });

  group('HU-25: A3b Cambiar contraseña', () {
    Widget pantalla(MockAuthRepository repo) => ChangeNotifierProvider(
      create: (_) => CambiarPasswordViewModel(authRepository: repo),
      child: const CambiarPasswordScreen(),
    );

    Future<void> llenar(WidgetTester tester, {required String actual, required String nueva}) async {
      await tester.enterText(find.byKey(const Key('password_actual')), actual);
      await tester.enterText(find.byKey(const Key('password_nueva')), nueva);
      await tester.enterText(find.byKey(const Key('password_confirmar')), nueva);
      await tester.ensureVisible(find.byKey(const Key('password_cambiar')));
      await tester.tap(find.byKey(const Key('password_cambiar')));
      await tester.pumpAndSettle();
    }

    testWidgets('Una nueva igual a la actual no se manda', (tester) async {
      final repo = MockAuthRepository();
      await _abrirPantalla(tester, pantalla(repo));

      await llenar(tester, actual: 'abc12345', nueva: 'abc12345');

      expect(find.text('Debe ser distinta de la actual'), findsOneWidget);
      verifyNever(() => repo.cambiarPassword(actual: any(named: 'actual'), nueva: any(named: 'nueva')));
    });

    testWidgets('Una nueva sin números no cumple la política', (tester) async {
      final repo = MockAuthRepository();
      await _abrirPantalla(tester, pantalla(repo));

      await llenar(tester, actual: 'abc12345', nueva: 'abcdefgh');

      expect(find.text('Debe incluir números'), findsOneWidget);
      verifyNever(() => repo.cambiarPassword(actual: any(named: 'actual'), nueva: any(named: 'nueva')));
    });

    testWidgets('Si la actual es incorrecta muestra el mensaje del servidor', (tester) async {
      final repo = MockAuthRepository();
      when(() => repo.cambiarPassword(actual: any(named: 'actual'), nueva: any(named: 'nueva')))
          .thenAnswer((_) async => const Result.error(PeticionRechazada(400, 'La contraseña actual no es correcta')));
      await _abrirPantalla(tester, pantalla(repo));

      await llenar(tester, actual: 'mala1234', nueva: 'nueva2026');

      expect(find.text('La contraseña actual no es correcta'), findsOneWidget);
      verify(() => repo.cambiarPassword(actual: 'mala1234', nueva: 'nueva2026')).called(1);
      expect(find.byType(CambiarPasswordScreen), findsOneWidget);
    });

    testWidgets('Con datos válidos cambia la contraseña y regresa con el aviso', (tester) async {
      final repo = MockAuthRepository();
      when(() => repo.cambiarPassword(actual: any(named: 'actual'), nueva: any(named: 'nueva')))
          .thenAnswer((_) async => const Result.ok('Contraseña actualizada'));
      await _abrirPantalla(tester, pantalla(repo));

      await llenar(tester, actual: 'abc12345', nueva: 'nueva2026');

      expect(find.byType(CambiarPasswordScreen), findsNothing);
      expect(_resultado, 'Contraseña actualizada');
    });
  });
}
