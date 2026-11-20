// Test tipo Interfaz: se prueba una pantalla, lo que se ve y se toca

import 'package:fix_flow/core/result.dart';
import 'package:fix_flow/domain/entities/prioridad.dart';
import 'package:fix_flow/domain/entities/tipo_incidencia.dart';
import 'package:fix_flow/presentation/admin/catalogo/catalogo_tipos_screen.dart';
import 'package:fix_flow/presentation/admin/catalogo/catalogo_tipos_viewmodel.dart';
import 'package:fix_flow/presentation/admin/catalogo/tipo_form_screen.dart';
import 'package:fix_flow/presentation/admin/catalogo/tipo_form_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:fix_flow/presentation/core/theme/app_theme.dart';
import '../mocks.dart';

void main() {
  late MockIncidenceTypeRepository mockTipos;

  setUp(() {
    mockTipos = MockIncidenceTypeRepository();
  });

  const tipo1 = TipoIncidencia(
    id: '1',
    nombre: 'Fuga de agua',
    codigo: 'FUGA_DE_AGUA',
    orientacion: OrientacionFoto.sinRestriccion,
    prioridadBase: Prioridad.alta,
    activo: true,
  );

  void configurarPantallaGrande(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('HU-26: Pantallas de catálogo de tipos de incidencia', () {
    testWidgets('Catálogo E10 con contador y diálogo de desactivación E12a', (tester) async {
      configurarPantallaGrande(tester);
      when(() => mockTipos.catalogo()).thenAnswer((_) async => const Result.ok([tipo1]));
      when(() => mockTipos.cambiarEstatus('1', activo: false)).thenAnswer((_) async => const Result.ok(tipo1));

      final vm = CatalogoTiposViewModel(tiposRepository: mockTipos);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: ChangeNotifierProvider<CatalogoTiposViewModel>.value(
            value: vm,
            child: const CatalogoTiposScreen(),
          ),
        ),
      );

      await vm.cargar();
      await tester.pumpAndSettle();

      expect(find.text('Catálogo de tipos'), findsOneWidget);
      expect(find.text('Fuga de agua'), findsOneWidget);
      expect(find.text('FUGA_DE_AGUA'), findsOneWidget);

      // Tocar botón Desactivar
      final btnDesactivar = find.byKey(const Key('estatus_tipo_1'));
      expect(btnDesactivar, findsOneWidget);
      await tester.tap(btnDesactivar);
      await tester.pumpAndSettle();

      // Diálogo de confirmación E12a
      expect(find.text('¿Desactivar Fuga de agua?'), findsOneWidget);

      // Confirmar desactivación
      final confirmarBtn = find.byKey(const Key('confirmar_estatus_tipo'));
      await tester.tap(confirmarBtn);
      await tester.pumpAndSettle();

      verify(() => mockTipos.cambiarEstatus('1', activo: false)).called(1);
    });

    testWidgets('Formularios E11 y E12 con código bloqueado en edición', (tester) async {
      configurarPantallaGrande(tester);
      // E11: Alta (tipo = null), campo de código es editable y sugiere código
      final vmAlta = TipoFormViewModel(tiposRepository: mockTipos);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: ChangeNotifierProvider<TipoFormViewModel>.value(
            value: vmAlta,
            child: const TipoFormScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Nuevo tipo'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // nombre y código

      // E12: Edición (tipo != null), campo de código aparece bloqueado (no es TextFormField)
      final vmEdicion = TipoFormViewModel(tiposRepository: mockTipos, tipo: tipo1);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: ChangeNotifierProvider<TipoFormViewModel>.value(
            value: vmEdicion,
            child: const TipoFormScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Editar tipo'), findsOneWidget);
      expect(find.text('FUGA_DE_AGUA'), findsOneWidget);
      expect(find.text('El código no se puede cambiar.'), findsOneWidget);
    });
  });
}
