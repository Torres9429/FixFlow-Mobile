// Test tipo Interfaz: se prueba una pantalla, lo que se ve y se toca

import 'package:fix_flow/domain/repositories/auth_repository.dart';
import 'package:fix_flow/presentation/auth/registro/registro_screen.dart';
import 'package:fix_flow/presentation/auth/registro/registro_viewmodel.dart';
import 'package:fix_flow/presentation/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import '../mocks.dart';

void main() {
  group('HU-01: Registro de ciudadano', () {
    testWidgets('Enviar el formulario vacío (CA-2): aparece error bajo cada campo y registrar() no se llama',
        (tester) async {
      final repo = MockAuthRepository();

      // Montar directamente la pantalla de registro con su ViewModel
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: ChangeNotifierProvider(
            create: (_) => RegistroViewModel(authRepository: repo),
            child: const RegistroScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verificar que estamos en la pantalla de registro
      expect(find.byType(RegistroScreen), findsOneWidget);

      // Hacer scroll hasta el botón "Crear cuenta" y tocarlo sin llenar nada
      await tester.ensureVisible(find.byKey(const Key('registro_crear')));
      await tester.tap(find.byKey(const Key('registro_crear')));
      await tester.pumpAndSettle();

      // Debe aparecer "Campo obligatorio" bajo cada campo vacío
      expect(find.text('Campo obligatorio'), findsAtLeast(1));

      // registrar() del repositorio nunca se llamó
      verifyNever(() => repo.registrar(
            nombre: any(named: 'nombre'),
            apellidos: any(named: 'apellidos'),
            correo: any(named: 'correo'),
            password: any(named: 'password'),
          ));
    });
  });
}
