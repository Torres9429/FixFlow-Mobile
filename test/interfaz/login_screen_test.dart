// Test tipo Interfaz: se prueba una pantalla, lo que se ve y se toca

import 'package:fix_flow/app.dart';
import 'package:fix_flow/core/result.dart';
import 'package:fix_flow/domain/errors/auth_failure.dart';
import 'package:fix_flow/presentation/auth/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks.dart';

void main() {
  group('HU-02: Inicio de sesión', () {
    testWidgets('El mock responde "credenciales no válidas" (CA-4): se muestra el mensaje y sigue en el login',
        (tester) async {
      // El repositorio simulado siempre rechaza las credenciales
      final repo = MockAuthRepository();
      when(() => repo.iniciarSesion(any(), any()))
          .thenAnswer((_) async => const Result.error(CredencialesInvalidas()));

      await tester.pumpWidget(FixFlowApp(authRepository: repo));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('login_correo')), 'ana@mail.com');
      await tester.enterText(find.byKey(const Key('login_password')), 'mala1234');
      await tester.ensureVisible(find.byKey(const Key('login_entrar')));
      await tester.tap(find.byKey(const Key('login_entrar')));
      await tester.pumpAndSettle();

      expect(find.text('Correo o contraseña no válidos'), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}
