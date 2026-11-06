// Test tipo Interfaz: se prueba una pantalla, lo que se ve y se toca

import 'package:fix_flow/app.dart';
import 'package:fix_flow/core/result.dart';
import 'package:fix_flow/core/sesion/sesion_expirada.dart';
import 'package:fix_flow/domain/entities/incidencia_resumen.dart';
import 'package:fix_flow/domain/entities/pagina.dart';
import 'package:fix_flow/domain/entities/rol.dart';
import 'package:fix_flow/domain/entities/usuario.dart';
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

    testWidgets('Si la sesión vence estando dentro (RNF-09), regresa al login con el aviso', (tester) async {
      final repo = MockAuthRepository();
      when(() => repo.iniciarSesion(any(), any()))
          .thenAnswer((_) async => const Result.ok(Usuario(nombre: 'Ana', rol: Rol.ciudadano)));
      when(() => repo.nombreUsuario()).thenAnswer((_) async => 'Ana');
      final reportes = MockReportesCiudadanoRepository();
      when(() => reportes.misReportes(estado: any(named: 'estado'), pagina: any(named: 'pagina')))
          .thenAnswer((_) async => const Result.ok(Pagina<IncidenciaResumen>(contenido: [], numero: 0, totalPaginas: 0)));
      final sesion = SesionExpirada();

      await tester.pumpWidget(
        FixFlowApp(authRepository: repo, reportesCiudadanoRepository: reportes, sesionExpirada: sesion),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('login_correo')), 'ana@mail.com');
      await tester.enterText(find.byKey(const Key('login_password')), 'buena1234');
      await tester.ensureVisible(find.byKey(const Key('login_entrar')));
      await tester.tap(find.byKey(const Key('login_entrar')));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsNothing);

      // ApiClient avisa que ya no pudo renovar el token
      sesion.avisar();
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byKey(const Key('login_sesion_vencida')), findsOneWidget);
    });
  });
}
