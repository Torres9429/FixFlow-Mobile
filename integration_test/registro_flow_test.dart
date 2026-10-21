// Test tipo Integración: la app completa en el emulador, con los servicios simulados

import 'package:fix_flow/app.dart';
import 'package:fix_flow/data/datasources/local/session_storage.dart';
import 'package:fix_flow/data/datasources/remote/fake_auth_remote_datasource.dart';
import 'package:fix_flow/data/repositories/auth_repository_impl.dart';
import 'package:fix_flow/presentation/auth/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/mocks.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('HU-01: Registro exitoso de punta a punta (CA-1, CA-6)', () {
    testWidgets('Llenar el formulario → Crear cuenta → la app llega al login y muestra "Cuenta creada"',
        (tester) async {
      final storage = crearStorageEnMemoria();
      final session = SessionStorage(storage);
      final repo = AuthRepositoryImpl(remote: FakeAuthRemoteDataSource(), session: session);

      await tester.pumpWidget(FixFlowApp(authRepository: repo));
      await tester.pumpAndSettle();

      // PASO 1: navegar a registro desde el login (en pantallas chicas el enlace queda abajo del borde)
      await tester.ensureVisible(find.text('Crea una'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Crea una'));
      await tester.pumpAndSettle();

      // PASO 2: llenar el formulario con datos nuevos (correo que NO existe en el fake)
      await tester.enterText(find.byKey(const Key('registro_nombre')), 'Carlos');
      await tester.enterText(find.byKey(const Key('registro_apellidos')), 'García López');
      await tester.enterText(find.byKey(const Key('registro_correo')), 'carlos@mail.com');
      await tester.enterText(find.byKey(const Key('registro_password')), 'abc12345');
      await tester.enterText(find.byKey(const Key('registro_confirmar')), 'abc12345');

      // PASO 3: tocar "Crear cuenta"
      await tester.ensureVisible(find.byKey(const Key('registro_crear')));
      await tester.tap(find.byKey(const Key('registro_crear')));
      await tester.pumpAndSettle();

      // PASO 4: la app llega al login y muestra "Cuenta creada"
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Cuenta creada'), findsOneWidget);
    });
  });
}
