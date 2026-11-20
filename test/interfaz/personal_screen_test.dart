// Test tipo Interfaz: se prueba una pantalla, lo que se ve y se toca

import 'package:fix_flow/core/result.dart';
import 'package:fix_flow/domain/entities/operativo.dart';
import 'package:fix_flow/presentation/admin/personal/alta_operativo_screen.dart';
import 'package:fix_flow/presentation/admin/personal/alta_operativo_viewmodel.dart';
import 'package:fix_flow/presentation/admin/personal/personal_screen.dart';
import 'package:fix_flow/presentation/admin/personal/personal_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:fix_flow/presentation/core/theme/app_theme.dart';
import '../mocks.dart';

void main() {
  late MockAdminRepository mockAdmin;

  setUp(() {
    mockAdmin = MockAdminRepository();
  });

  const op1 = Operativo(
    id: 1,
    nombre: 'Roberto',
    apellidos: 'Mendoza',
    correo: 'roberto@fixflow.mx',
    activo: true,
    cargaActual: 2,
  );

  void configurarPantallaGrande(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('HU-24: Pantallas de gestión de personal operativo', () {
    testWidgets('Pantalla E8 con switch de estatus y confirmación', (tester) async {
      configurarPantallaGrande(tester);
      when(() => mockAdmin.listarOperativos()).thenAnswer((_) async => const Result.ok([op1]));
      when(() => mockAdmin.cambiarEstatusOperativo(1, activo: false)).thenAnswer((_) async => const Result.ok(null));

      final vm = PersonalViewModel(adminRepository: mockAdmin);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: ChangeNotifierProvider<PersonalViewModel>.value(
            value: vm,
            child: const PersonalScreen(),
          ),
        ),
      );

      await vm.iniciar();
      await tester.pumpAndSettle();

      expect(find.text('Roberto Mendoza'), findsOneWidget);
      expect(find.text('roberto@fixflow.mx'), findsOneWidget);
      expect(find.text('2 incidencias activas'), findsOneWidget);

      // Tocar botón Desactivar
      final botonDesactivar = find.byKey(const Key('estatus_operativo_1'));
      expect(botonDesactivar, findsOneWidget);
      await tester.tap(botonDesactivar);
      await tester.pumpAndSettle();

      // Debe aparecer el diálogo modal de confirmación
      expect(find.text('¿Desactivar operativo?'), findsOneWidget);
      expect(find.text('Desactivar operativo'), findsWidgets);

      // Confirmar en el modal
      final btnConfirmar = find.widgetWithText(FilledButton, 'Desactivar operativo');
      await tester.tap(btnConfirmar);
      await tester.pumpAndSettle();

      verify(() => mockAdmin.cambiarEstatusOperativo(1, activo: false)).called(1);
    });

    testWidgets('Formulario de alta E9 y botón de copia de contraseña', (tester) async {
      configurarPantallaGrande(tester);
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async => null,
      );
      when(() => mockAdmin.crearOperativo(
            nombre: any(named: 'nombre'),
            apellidos: any(named: 'apellidos'),
            correo: any(named: 'correo'),
            passwordTemporal: any(named: 'passwordTemporal'),
          )).thenAnswer((_) async => const Result.ok(null));

      final vm = AltaOperativoViewModel(adminRepository: mockAdmin);

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
                    key: const Key('abrir_alta'),
                    onPressed: () => context.push('/alta'),
                    child: const Text('abrir'),
                  ),
                ),
              ),
              GoRoute(
                path: '/alta',
                builder: (context, state) => ChangeNotifierProvider<AltaOperativoViewModel>.value(
                  value: vm,
                  child: const AltaOperativoScreen(),
                ),
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('abrir_alta')));
      await tester.pumpAndSettle();

      await tester.pumpAndSettle();

      expect(find.text('Registrar nuevo operador'), findsOneWidget);

      // Llenar formulario
      await tester.enterText(find.byKey(const Key('operativo_nombre')), 'Roberto');
      await tester.enterText(find.byKey(const Key('operativo_apellidos')), 'Mendoza');
      await tester.enterText(find.byKey(const Key('operativo_correo')), 'roberto@fixflow.mx');
      await tester.pumpAndSettle();

      // Enviar
      await tester.ensureVisible(find.byKey(const Key('crear_operativo')));
      await tester.tap(find.byKey(const Key('crear_operativo')));
      await tester.pumpAndSettle();

      // Aparece la hoja de confirmación con las credenciales y el botón de copiar
      expect(find.text('Operativo registrado'), findsOneWidget);
      expect(find.byKey(const Key('alta_copiar_password')), findsOneWidget);
      expect(find.text('Copiar contraseña'), findsOneWidget);

      // Tocar copiar contraseña cierra la hoja y regresa a inicio
      await tester.tap(find.byKey(const Key('alta_copiar_password')));
      await tester.pumpAndSettle();
      expect(find.text('Operativo registrado'), findsNothing);
    });
  });
}
