// Test tipo Interfaz: se prueba una pantalla, lo que se ve y se toca

import 'package:fix_flow/core/result.dart';
import 'package:fix_flow/domain/entities/incidencia_resumen.dart';
import 'package:fix_flow/domain/entities/pagina.dart';
import 'package:fix_flow/presentation/ciudadano/mis_reportes/mis_reportes_screen.dart';
import 'package:fix_flow/presentation/ciudadano/mis_reportes/mis_reportes_viewmodel.dart';
import 'package:fix_flow/presentation/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import '../mocks.dart';

void main() {
  group('HU-10: Mis reportes', () {
    testWidgets('Sin reportes (C4): mensaje y «Hacer un reporte», sin saludo ni chips', (tester) async {
      final auth = MockAuthRepository();
      when(() => auth.nombreUsuario()).thenAnswer((_) async => 'Ana');
      final repo = MockReportesCiudadanoRepository();
      when(
        () => repo.misReportes(
          estado: any(named: 'estado'),
          pagina: any(named: 'pagina'),
        ),
      ).thenAnswer((_) async => const Result.ok(Pagina<IncidenciaResumen>(contenido: [], numero: 0, totalPaginas: 0)));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: ChangeNotifierProvider(
            create: (_) => MisReportesViewModel(reportesRepository: repo, authRepository: auth)..iniciar(),
            child: const MisReportesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('mis_reportes_vacio')), findsOneWidget);
      expect(find.text('Sin reportes registrados'), findsOneWidget);
      expect(find.text('Hacer un reporte'), findsOneWidget);
      expect(find.text('Todas'), findsNothing);
      expect(find.text('Hola, Ana'), findsNothing);
    });
  });
}
