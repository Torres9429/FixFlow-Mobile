// Test tipo Interfaz: se prueba una pantalla, lo que se ve y se toca

import 'package:fix_flow/core/result.dart';
import 'package:fix_flow/domain/entities/estado_incidencia.dart';
import 'package:fix_flow/domain/entities/incidencia_detalle.dart';
import 'package:fix_flow/domain/entities/incidencia_resumen.dart';
import 'package:fix_flow/domain/entities/operativo.dart';
import 'package:fix_flow/domain/entities/prioridad.dart';
import 'package:fix_flow/domain/repositories/direccion_repository.dart';
import 'package:fix_flow/presentation/admin/asignacion/asignacion_screen.dart';
import 'package:fix_flow/presentation/admin/asignacion/asignacion_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:fix_flow/presentation/core/theme/app_theme.dart';
import '../mocks.dart';

class MockDireccionRepository extends Mock implements DireccionRepository {}

void main() {
  late MockAdminRepository mockAdmin;
  late MockIncidenciasRepository mockIncidencias;
  late MockDireccionRepository mockDireccion;

  setUp(() {
    mockAdmin = MockAdminRepository();
    mockIncidencias = MockIncidenciasRepository();
    mockDireccion = MockDireccionRepository();
  });

  void configurarPantallaGrande(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  testWidgets('Pantalla E5/E6 muestra lista con carga actual y selección', (tester) async {
    configurarPantallaGrande(tester);
    final detalle = IncidenciaDetalle(
      resumen: IncidenciaResumen(
        id: 50,
        folio: 'FX-2026-000050',
        tipo: 'Bache',
        tipoCodigo: 'BACHE',
        estado: EstadoIncidencia.pendiente,
        prioridad: Prioridad.alta,
        motivoPrioridad: 'Prioridad alta',
        latitud: 18.92,
        longitud: -99.23,
        fechaCreacion: DateTime(2026, 11, 1),
        ultimaActualizacion: DateTime(2026, 11, 2),
      ),
      descripcion: 'Bache grande',
      numReaperturas: 0,
      ciudadano: 'Ana',
    );

    final operativos = [
      const Operativo(
        id: 10,
        nombre: 'Luis',
        apellidos: 'Ramírez',
        correo: 'luis@fixflow.mx',
        activo: true,
        cargaActual: 3,
      ),
    ];

    when(() => mockIncidencias.detalle(50)).thenAnswer((_) async => Result.ok(detalle));
    when(() => mockAdmin.operativosDisponibles()).thenAnswer((_) async => Result.ok(operativos));
    when(() => mockDireccion.direccion(any(), any())).thenAnswer((_) async => 'Calle Hidalgo 45');

    final vm = AsignacionViewModel(
      id: 50,
      adminRepository: mockAdmin,
      direccionRepository: mockDireccion,
      incidenciasRepository: mockIncidencias,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: ChangeNotifierProvider<AsignacionViewModel>.value(
          value: vm,
          child: const AsignacionScreen(),
        ),
      ),
    );

    await vm.iniciar();
    await tester.pumpAndSettle();

    expect(find.text('Asignar incidencia'), findsOneWidget);
    expect(find.text('Luis Ramírez'), findsOneWidget);
    expect(find.text('3 incidencias activas'), findsOneWidget);
    expect(find.byKey(const Key('confirmar_asignacion')), findsOneWidget);
  });
}
