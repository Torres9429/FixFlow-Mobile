// Test tipo Interfaz: se prueba una pantalla, lo que se ve y se toca

import 'package:fix_flow/data/repositories/fakes/fake_avisos_repository.dart';
import 'package:fix_flow/domain/entities/accion_aviso.dart';
import 'package:fix_flow/domain/entities/aviso.dart';
import 'package:fix_flow/domain/entities/rol.dart';
import 'package:fix_flow/presentation/avisos/avisos_screen.dart';
import 'package:fix_flow/presentation/avisos/avisos_viewmodel.dart';
import 'package:fix_flow/presentation/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  Future<AvisosViewModel> abrir(WidgetTester tester, List<Aviso> avisos) async {
    final vm = AvisosViewModel(avisosRepository: FakeAvisosRepository(avisos: avisos));
    await vm.cargar();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: ChangeNotifierProvider.value(value: vm, child: const AvisosScreen(rol: Rol.operativo)),
      ),
    );
    await tester.pump();
    return vm;
  }

  Aviso aviso(int id, String titulo, Duration hace, {bool leida = false}) => Aviso(
    id: id,
    titulo: titulo,
    mensaje: 'FX-2026-000097',
    leida: leida,
    fecha: DateTime.now().subtract(hace),
    incidenciaId: 97,
    folio: 'FX-2026-000097',
    accion: AccionAviso.reapertura,
  );

  testWidgets('D6: muestra los avisos agrupados y «Marcar todo como leído» los deja leídos (HU-12)', (tester) async {
    final vm = await abrir(tester, [
      aviso(2, 'Incidencia reabierta', const Duration(minutes: 30)),
      aviso(1, 'Nueva incidencia asignada', const Duration(days: 3), leida: true),
    ]);

    expect(find.text('Hoy'), findsOneWidget);
    expect(find.text('Esta semana'), findsOneWidget);
    expect(find.text('Incidencia reabierta'), findsOneWidget);
    expect(find.text('hace 30 min'), findsOneWidget);

    await tester.tap(find.byKey(const Key('marcar_todo_leido')));
    await tester.pump();

    expect(vm.hayNoLeidos, isFalse);
    final boton = tester.widget<TextButton>(find.byKey(const Key('marcar_todo_leido')));
    expect(boton.onPressed, isNull);
  });

  testWidgets('Sin avisos se explica qué va a llegar', (tester) async {
    await abrir(tester, const []);

    expect(find.text('No tienes avisos'), findsOneWidget);
    expect(find.text('Aquí verás las incidencias que te asignen o que se reabran.'), findsOneWidget);
  });
}
