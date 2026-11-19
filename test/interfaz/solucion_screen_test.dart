import 'package:fix_flow/core/result.dart';
import 'package:fix_flow/domain/entities/estado_incidencia.dart';
import 'package:fix_flow/domain/entities/evento_historial.dart';
import 'package:fix_flow/domain/entities/incidencia_detalle.dart';
import 'package:fix_flow/domain/entities/incidencia_resumen.dart';
import 'package:fix_flow/domain/entities/prioridad.dart';
import 'package:fix_flow/domain/errors/falla_red.dart';
import 'package:fix_flow/domain/repositories/direccion_repository.dart';
import 'package:fix_flow/domain/repositories/evidencia_repository.dart';
import 'package:fix_flow/presentation/core/theme/app_theme.dart';
import 'package:fix_flow/presentation/incidencia/detalle_incidencia_screen.dart';
import 'package:fix_flow/presentation/incidencia/detalle_incidencia_viewmodel.dart';
import 'package:fix_flow/presentation/incidencia/vista_detalle.dart';
import 'package:fix_flow/presentation/operativo/solucion/solucion_screen.dart';
import 'package:fix_flow/presentation/operativo/solucion/solucion_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import '../mocks.dart';

class _MockDireccionRepository extends Mock implements DireccionRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(TipoEvidencia.reporte);
  });

  group('HU-16 / Issue #70: SolucionScreen (D3) y botón en D2', () {
    late MockOperativoRepository mockOperativoRepo;
    late MockEvidenciaRepository mockEvidenciaRepo;
    late MockUbicacionRepository mockUbicacionRepo;
    late MockAuthRepository mockAuthRepo;

    setUp(() {
      mockOperativoRepo = MockOperativoRepository();
      mockEvidenciaRepo = MockEvidenciaRepository();
      mockUbicacionRepo = MockUbicacionRepository();
      mockAuthRepo = MockAuthRepository();
      when(() => mockAuthRepo.nombreUsuario()).thenAnswer((_) async => 'Luis Ramírez');
      when(() => mockUbicacionRepo.posicionActual()).thenAnswer((_) async => null);
    });

    Widget construirD3({Future<String?> Function(BuildContext)? onTomarFoto}) {
      final router = GoRouter(
        initialLocation: '/solucion',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const Scaffold(body: Text('Inicio')),
            routes: [
              GoRoute(
                path: 'solucion',
                builder: (_, _) => ChangeNotifierProvider(
                  create: (_) => SolucionViewModel(
                    id: 123,
                    operativoRepository: mockOperativoRepo,
                    evidenciaRepository: mockEvidenciaRepo,
                    ubicacionRepository: mockUbicacionRepo,
                    authRepository: mockAuthRepo,
                  )..iniciar(),
                  child: SolucionScreen(onTomarFoto: onTomarFoto),
                ),
              ),
            ],
          ),
        ],
      );
      return MaterialApp.router(theme: AppTheme.light, routerConfig: router);
    }

    testWidgets('muestra campos iniciales según design.md y valida al enviar vacío', (tester) async {
      await tester.pumpWidget(construirD3());
      await tester.pumpAndSettle();

      expect(find.text('Registrar solución'), findsOneWidget);
      expect(find.text('Tomar foto'), findsOneWidget);
      expect(find.text('0/500'), findsOneWidget);
      expect(find.text('Se registrará a nombre de Luis Ramírez'), findsOneWidget);
      expect(find.text('La incidencia pasará a Resuelta'), findsOneWidget);
      expect(find.text('Enviar solución'), findsOneWidget);

      await tester.tap(find.byKey(const Key('solucion_enviar')));
      await tester.pumpAndSettle();

      expect(find.text('Toma una foto del trabajo terminado'), findsNWidgets(2));
      expect(find.text('Campo obligatorio'), findsOneWidget);
      verifyNever(() => mockEvidenciaRepo.subirFoto(any(), tipo: any(named: 'tipo')));
    });

    testWidgets('toma foto, captura descripción, envía solución SOLUCION y muestra snackbar', (tester) async {
      when(() => mockEvidenciaRepo.subirFoto('/tmp/foto_sol.jpg', tipo: TipoEvidencia.solucion))
          .thenAnswer((_) async => const Result.ok('https://cdn.example/foto_sol.jpg'));
      when(
        () => mockOperativoRepo.registrarSolucion(
          incidenciaId: 123,
          descripcion: 'Se cambió el tramo de tubería.',
          fotoUrl: 'https://cdn.example/foto_sol.jpg',
          latitud: null,
          longitud: null,
        ),
      ).thenAnswer((_) async => const Result.ok(null));

      await tester.pumpWidget(
        construirD3(onTomarFoto: (_) async => '/tmp/foto_sol.jpg'),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('solucion_tomar_foto')));
      await tester.pumpAndSettle();
      expect(find.text('Volver a capturar'), findsOneWidget);

      await tester.ensureVisible(find.byKey(const Key('solucion_descripcion')));
      await tester.enterText(
        find.byKey(const Key('solucion_descripcion')),
        'Se cambió el tramo de tubería.',
      );
      await tester.pump();
      expect(find.text('30/500'), findsOneWidget);

      await tester.tap(find.byKey(const Key('solucion_enviar')));
      await tester.pumpAndSettle();

      verify(() => mockEvidenciaRepo.subirFoto('/tmp/foto_sol.jpg', tipo: TipoEvidencia.solucion)).called(1);
      verify(
        () => mockOperativoRepo.registrarSolucion(
          incidenciaId: 123,
          descripcion: 'Se cambió el tramo de tubería.',
          fotoUrl: 'https://cdn.example/foto_sol.jpg',
          latitud: null,
          longitud: null,
        ),
      ).called(1);
      expect(find.text('Solución registrada'), findsOneWidget);
    });

    testWidgets('muestra el error del servidor si registrarSolucion falla', (tester) async {
      when(() => mockEvidenciaRepo.subirFoto('/tmp/foto_sol.jpg', tipo: TipoEvidencia.solucion))
          .thenAnswer((_) async => const Result.ok('https://cdn.example/foto_sol.jpg'));
      when(
        () => mockOperativoRepo.registrarSolucion(
          incidenciaId: any(named: 'incidenciaId'),
          descripcion: any(named: 'descripcion'),
          fotoUrl: any(named: 'fotoUrl'),
          latitud: any(named: 'latitud'),
          longitud: any(named: 'longitud'),
        ),
      ).thenAnswer(
        (_) async => const Result.error(Conflicto('Solo se registra la solución de una incidencia En proceso')),
      );

      await tester.pumpWidget(
        construirD3(onTomarFoto: (_) async => '/tmp/foto_sol.jpg'),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('solucion_tomar_foto')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('solucion_descripcion')));
      await tester.enterText(find.byKey(const Key('solucion_descripcion')), 'Reparación lista');
      await tester.tap(find.byKey(const Key('solucion_enviar')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('solucion_error')), findsOneWidget);
      expect(find.text('Solo se registra la solución de una incidencia En proceso'), findsOneWidget);
    });

    testWidgets('D2 muestra botón «Registrar solución» cuando la incidencia está En proceso para operativo',
        (tester) async {
      final mockIncidencias = MockIncidenciasRepository();
      final mockDireccion = _MockDireccionRepository();
      when(() => mockIncidencias.detalle(123)).thenAnswer(
        (_) async => Result.ok(
          IncidenciaDetalle(
            resumen: IncidenciaResumen(
              id: 123,
              folio: 'FX-2026-000123',
              tipo: 'Bache',
              tipoCodigo: 'BACHE',
              estado: EstadoIncidencia.enProceso,
              prioridad: Prioridad.media,
              motivoPrioridad: 'Tipo de incidencia: Bache',
              latitud: 18.92,
              longitud: -99.23,
              fechaCreacion: DateTime(2026, 3, 1),
              ultimaActualizacion: DateTime(2026, 3, 2),
              operativo: 'Luis Ramírez',
            ),
            descripcion: 'Bache en avenida',
            numReaperturas: 0,
            operativoAsignado: 'Luis Ramírez',
          ),
        ),
      );
      when(() => mockIncidencias.historial(123)).thenAnswer((_) async => const Result.ok(<EventoHistorial>[]));
      when(() => mockDireccion.direccion(any(), any())).thenAnswer((_) async => 'Av. Universidad 10');

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: ChangeNotifierProvider(
            create: (_) => DetalleIncidenciaViewModel(
              id: 123,
              vista: VistaDetalle.operativo,
              incidenciasRepository: mockIncidencias,
              direccionRepository: mockDireccion,
              operativoRepository: mockOperativoRepo,
            )..iniciar(),
            child: const DetalleIncidenciaScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('detalle_registrar_solucion')), findsOneWidget);
      expect(find.text('Registrar solución'), findsOneWidget);
    });
  });
}
