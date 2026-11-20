// Test tipo Interfaz: se prueba una pantalla, lo que se ve y se toca

import 'package:fix_flow/core/result.dart';
import 'package:fix_flow/domain/entities/estado_incidencia.dart';
import 'package:fix_flow/domain/entities/incidencia_resumen.dart';
import 'package:fix_flow/domain/entities/pagina.dart';
import 'package:fix_flow/domain/entities/prioridad.dart';
import 'package:fix_flow/domain/entities/tipo_incidencia.dart';
import 'package:fix_flow/presentation/admin/incidencias/incidencias_admin_screen.dart';
import 'package:fix_flow/presentation/admin/incidencias/incidencias_admin_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:fix_flow/presentation/core/theme/app_theme.dart';
import '../mocks.dart';

void main() {
  late MockAdminRepository mockAdmin;
  late MockIncidenceTypeRepository mockTipos;

  setUp(() {
    mockAdmin = MockAdminRepository();
    mockTipos = MockIncidenceTypeRepository();
    when(() => mockTipos.obtenerTipos()).thenAnswer((_) async => const Result.ok(<TipoIncidencia>[]));
  });

  void configurarPantallaGrande(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  testWidgets('Renderizado de listado municipal E2 y pie de página', (tester) async {
    configurarPantallaGrande(tester);
    final i1 = IncidenciaResumen(
      id: 1,
      folio: 'FX-2026-000001',
      tipo: 'Bache',
      tipoCodigo: 'BACHE',
      estado: EstadoIncidencia.pendiente,
      prioridad: Prioridad.alta,
      motivoPrioridad: 'Prioridad alta',
      latitud: 18.92,
      longitud: -99.23,
      fechaCreacion: DateTime(2026, 11, 4),
      ultimaActualizacion: DateTime(2026, 11, 4),
    );

    when(() => mockAdmin.incidencias(
          estado: any(named: 'estado'),
          prioridad: any(named: 'prioridad'),
          tipoId: any(named: 'tipoId'),
          q: any(named: 'q'),
          pagina: any(named: 'pagina'),
          tamano: any(named: 'tamano'),
        )).thenAnswer(
      (_) async => Result.ok(Pagina(contenido: [i1], numero: 0, totalPaginas: 1)),
    );

    final vm = IncidenciasAdminViewModel(
      adminRepository: mockAdmin,
      tiposRepository: mockTipos,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: ChangeNotifierProvider<IncidenciasAdminViewModel>.value(
          value: vm,
          child: const IncidenciasAdminScreen(),
        ),
      ),
    );

    await vm.iniciar();
    await tester.pumpAndSettle();

    expect(find.text('Incidencias del municipio'), findsOneWidget);
    expect(find.text('Bache'), findsOneWidget);
    expect(find.byKey(const Key('incidencias_busqueda')), findsOneWidget);
    expect(find.text('Todas las incidencias del cuadrante sincronizadas'), findsOneWidget);
  });
}
