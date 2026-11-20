// Test tipo Interfaz: se prueba una pantalla, lo que se ve y se toca

import 'package:fix_flow/core/result.dart';
import 'package:fix_flow/domain/entities/estado_incidencia.dart';
import 'package:fix_flow/domain/entities/incidencia_resumen.dart';
import 'package:fix_flow/domain/entities/indicadores.dart';
import 'package:fix_flow/domain/entities/pagina.dart';
import 'package:fix_flow/domain/entities/prioridad.dart';
import 'package:fix_flow/presentation/admin/panel/panel_screen.dart';
import 'package:fix_flow/presentation/admin/panel/panel_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:fix_flow/presentation/core/theme/app_theme.dart';
import '../mocks.dart';

void main() {
  late MockAdminRepository mockAdmin;
  late MockAuthRepository mockAuth;

  setUp(() {
    mockAdmin = MockAdminRepository();
    mockAuth = MockAuthRepository();
    when(() => mockAuth.nombreUsuario()).thenAnswer((_) async => 'Carlos');
  });

  void configurarPantallaGrande(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  testWidgets('Panel E1 renderiza tarjetas de indicadores numéricos (CA-1, CA-2)', (tester) async {
    configurarPantallaGrande(tester);
    const indicadores = Indicadores(
      registradas: 128,
      pendientes: 42,
      enAtencion: 30,
      atendidas: 56,
      porPrioridad: {
        Prioridad.alta: 10,
        Prioridad.media: 20,
        Prioridad.baja: 12,
      },
    );

    final prioritarias = [
      IncidenciaResumen(
        id: 1,
        folio: 'FX-2026-000001',
        tipo: 'Fuga de agua',
        tipoCodigo: 'FUGA_AGUA',
        estado: EstadoIncidencia.pendiente,
        prioridad: Prioridad.alta,
        motivoPrioridad: 'Prioridad alta',
        latitud: 18.92,
        longitud: -99.23,
        fechaCreacion: DateTime(2026, 11, 4),
        ultimaActualizacion: DateTime(2026, 11, 4),
      ),
    ];

    when(() => mockAdmin.indicadores()).thenAnswer((_) async => const Result.ok(indicadores));
    when(() => mockAdmin.incidencias(
          estado: any(named: 'estado'),
          prioridad: any(named: 'prioridad'),
          pagina: any(named: 'pagina'),
          tamano: any(named: 'tamano'),
        )).thenAnswer((_) async => Result.ok(Pagina(contenido: prioritarias, numero: 0, totalPaginas: 1)));

    final vm = PanelViewModel(
      adminRepository: mockAdmin,
      authRepository: mockAuth,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: ChangeNotifierProvider<PanelViewModel>.value(
          value: vm,
          child: const PanelScreen(),
        ),
      ),
    );

    await vm.iniciar();
    await tester.pumpAndSettle();

    expect(find.text('Hola, Carlos'), findsOneWidget);
    expect(find.text('Panel del municipio'), findsOneWidget);
    expect(find.text('128'), findsOneWidget);
    expect(find.text('Registradas'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(find.text('Pendientes'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
    expect(find.text('En atención'), findsOneWidget);
    expect(find.text('56'), findsOneWidget);
    expect(find.text('Atendidas'), findsOneWidget);
    expect(find.text('Prioridad alta sin atender'), findsOneWidget);
  });
}
