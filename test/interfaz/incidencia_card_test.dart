// Test tipo Interfaz: se prueba una pantalla, lo que se ve y se toca

import 'package:fix_flow/domain/entities/estado_incidencia.dart';
import 'package:fix_flow/domain/entities/incidencia_resumen.dart';
import 'package:fix_flow/domain/entities/prioridad.dart';
import 'package:fix_flow/presentation/core/theme/app_theme.dart';
import 'package:fix_flow/presentation/core/widgets/incidencia_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final incidencia = IncidenciaResumen(
    id: 97,
    folio: 'FX-2026-000097',
    tipo: 'Fuga de agua',
    tipoCodigo: 'FUGA_AGUA',
    estado: EstadoIncidencia.resuelta,
    prioridad: Prioridad.alta,
    motivoPrioridad: 'Tipo de incidencia: Fuga de agua',
    latitud: 18.92,
    longitud: -99.23,
    fechaCreacion: DateTime(2026, 11, 4, 11, 30),
    ultimaActualizacion: DateTime(2026, 11, 4, 11, 30),
  );

  Future<void> montar(WidgetTester tester, {VoidCallback? onTap}) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: IncidenciaCard(
          incidencia: incidencia,
          meta: 'FX-2026-000097 · hoy, 11:30',
          direccion: 'Calle Morelos 892, Centro',
          accion: FilledButton(onPressed: () {}, child: const Text('Confirmar resolución')),
          onTap: onTap,
        ),
      ),
    ),
  );

  testWidgets('Tarjeta de incidencia: muestra estado, prioridad como símbolo, datos y acción', (tester) async {
    await montar(tester);

    expect(find.text('Resuelta'), findsOneWidget);
    // La tarjeta es un solo botón y junta las etiquetas; se busca la del símbolo directamente
    expect(find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Prioridad alta'), findsOneWidget);
    // La prioridad nunca va como texto en la tarjeta
    expect(find.text('Alta'), findsNothing);
    expect(find.text('Fuga de agua'), findsOneWidget);
    expect(find.text('Calle Morelos 892, Centro'), findsOneWidget);
    expect(find.text('FX-2026-000097 · hoy, 11:30'), findsOneWidget);
    expect(find.text('Confirmar resolución'), findsOneWidget);
  });

  testWidgets('Tarjeta de incidencia: tocarla abre el detalle', (tester) async {
    var abierta = false;
    await montar(tester, onTap: () => abierta = true);

    await tester.tap(find.text('Fuga de agua'));

    expect(abierta, isTrue);
  });
}
