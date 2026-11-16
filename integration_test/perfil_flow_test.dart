import 'package:fix_flow/app.dart';
import 'package:fix_flow/data/datasources/local/session_storage.dart';
import 'package:fix_flow/data/datasources/remote/fake_auth_remote_datasource.dart';
import 'package:fix_flow/data/repositories/auth_repository_impl.dart';
import 'package:fix_flow/presentation/perfil/perfil_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/mocks.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('HU-25: Gestionar mi perfil de punta a punta', () {
    testWidgets('ciudadano: edita su nombre, cambia su contraseña y entra con la nueva', (tester) async {
      final session = SessionStorage(crearStorageEnMemoria());
      final repo = AuthRepositoryImpl(remote: FakeAuthRemoteDataSource(), session: session);

      Future<void> entrar(String password) async {
        await tester.enterText(find.byKey(const Key('login_correo')), 'ciudadano@fixflow.mx');
        await tester.enterText(find.byKey(const Key('login_password')), password);
        await tester.ensureVisible(find.byKey(const Key('login_entrar')));
        await tester.tap(find.byKey(const Key('login_entrar')));
        await tester.pumpAndSettle();
      }

      await tester.pumpWidget(FixFlowApp(authRepository: repo));
      await tester.pumpAndSettle();
      await entrar(FakeAuthRemoteDataSource.passwordDemo);

      await tester.tap(find.byKey(const Key('abrir_perfil')));
      await tester.pumpAndSettle();
      expect(find.byType(PerfilScreen), findsOneWidget);
      expect(find.text('Ana López Ruiz'), findsOneWidget);

      await tester.tap(find.byKey(const Key('perfil_editar_datos')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('editar_nombre')), 'Ana María');
      await tester.ensureVisible(find.byKey(const Key('editar_guardar')));
      await tester.tap(find.byKey(const Key('editar_guardar')));
      await tester.pumpAndSettle();

      expect(find.text('Ana María López Ruiz'), findsOneWidget);
      expect(find.text('Tus datos se guardaron'), findsOneWidget);
      expect(await session.leerNombre(), 'Ana María');

      await tester.tap(find.byKey(const Key('perfil_cambiar_password')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('password_actual')), FakeAuthRemoteDataSource.passwordDemo);
      await tester.enterText(find.byKey(const Key('password_nueva')), 'nueva2026');
      await tester.enterText(find.byKey(const Key('password_confirmar')), 'nueva2026');
      await tester.ensureVisible(find.byKey(const Key('password_cambiar')));
      await tester.tap(find.byKey(const Key('password_cambiar')));
      await tester.pumpAndSettle();

      expect(find.byType(PerfilScreen), findsOneWidget);
      expect(find.text('Contraseña actualizada'), findsOneWidget);

      await tester.ensureVisible(find.byKey(const Key('cerrar_sesion')));
      await tester.tap(find.byKey(const Key('cerrar_sesion')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirmar_cerrar_sesion')));
      await tester.pumpAndSettle();

      await entrar('nueva2026');
      expect(await session.leerToken(), isNotNull);

      await repo.cambiarPassword(actual: 'nueva2026', nueva: FakeAuthRemoteDataSource.passwordDemo);
      await repo.actualizarPerfil(nombre: 'Ana', apellidos: 'López Ruiz');
    });
  });
}
