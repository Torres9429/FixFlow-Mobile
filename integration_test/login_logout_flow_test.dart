// Test tipo Integración: la app completa en el emulador, con los servicios simulados

import 'package:fix_flow/app.dart';
import 'package:fix_flow/data/datasources/local/session_storage.dart';
import 'package:fix_flow/data/datasources/remote/fake_auth_remote_datasource.dart';
import 'package:fix_flow/data/repositories/auth_repository_impl.dart';
import 'package:fix_flow/presentation/auth/login/login_screen.dart';
import 'package:fix_flow/presentation/home/home_admin_screen.dart';
import 'package:fix_flow/presentation/home/home_ciudadano_screen.dart';
import 'package:fix_flow/presentation/home/home_operativo_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

import '../test/mocks.dart';

void main() {
  // Conecta el motor de pruebas con el emulador: es OBLIGATORIO
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Cuenta demo del back simulado → home a la que debe llegar
  const flujos = {
    'ciudadano@fixflow.mx': HomeCiudadanoScreen,
    'operativo@fixflow.mx': HomeOperativoScreen,
    'admin@fixflow.mx': HomeAdminScreen,
  };

  group('HU-02: Login y cierre de sesión de punta a punta', () {
    for (final MapEntry(key: correo, value: home) in flujos.entries) {
      testWidgets('$correo: login → su home → cerrar sesión → login y el token queda borrado', (tester) async {
        // Repositorio real con el back simulado; el token va a un almacenamiento en memoria NUEVO
        final storage = crearStorageEnMemoria();
        final session = SessionStorage(storage);
        final repo = AuthRepositoryImpl(remote: FakeAuthRemoteDataSource(), session: session);

        await tester.pumpWidget(FixFlowApp(authRepository: repo));
        await tester.pumpAndSettle();

        // PASO 1: login
        await tester.enterText(find.byKey(const Key('login_correo')), correo);
        await tester.enterText(find.byKey(const Key('login_password')), FakeAuthRemoteDataSource.passwordDemo);
        await tester.ensureVisible(find.byKey(const Key('login_entrar')));
        await tester.tap(find.byKey(const Key('login_entrar')));
        await tester.pumpAndSettle();

        // PASO 2: llega a la home de su rol con el token guardado
        expect(find.byType(home), findsOneWidget);
        expect(await session.leerToken(), isNotNull);

        // PASO 3: cerrar sesión regresa al login y borra el token
        await tester.tap(find.byKey(const Key('cerrar_sesion')));
        await tester.pumpAndSettle();

        expect(find.byType(LoginScreen), findsOneWidget);
        verify(() => storage.delete(key: 'token')).called(1);
        expect(await session.leerToken(), isNull);
      });
    }
  });
}
