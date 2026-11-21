// Test tipo Integración: la app completa en el emulador, con los servicios simulados

import 'package:fix_flow/app.dart';
import 'package:fix_flow/core/result.dart';
import 'package:fix_flow/data/datasources/local/session_storage.dart';
import 'package:fix_flow/data/datasources/remote/fake_auth_remote_datasource.dart';
import 'package:fix_flow/data/repositories/auth_repository_impl.dart';
import 'package:fix_flow/data/repositories/fakes/fake_incidencias_repository.dart';
import 'package:fix_flow/data/repositories/fakes/fake_reportes_ciudadano_repository.dart';
import 'package:fix_flow/domain/entities/estado_incidencia.dart';
import 'package:fix_flow/domain/entities/incidencia_detalle.dart';
import 'package:fix_flow/domain/entities/incidencia_resumen.dart';
import 'package:fix_flow/domain/entities/pagina.dart';
import 'package:fix_flow/presentation/ciudadano/mis_reportes/mis_reportes_screen.dart';
import 'package:fix_flow/presentation/core/widgets/chips_filtro.dart';
import 'package:fix_flow/presentation/incidencia/detalle_incidencia_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/mocks.dart';

/// Lo que el back hace al confirmar: la incidencia pasa a Cerrada. Lo comparten los dos fakes de abajo,
/// para que B1 y C2 vean el mismo cambio, como pasaría con el servidor.
class _Servidor {
  final cerradas = <int>{};
  int confirmaciones = 0;

  IncidenciaResumen aplicar(IncidenciaResumen r) => !cerradas.contains(r.id)
      ? r
      : IncidenciaResumen(
          id: r.id,
          folio: r.folio,
          tipo: r.tipo,
          tipoCodigo: r.tipoCodigo,
          estado: EstadoIncidencia.cerrada,
          prioridad: r.prioridad,
          motivoPrioridad: r.motivoPrioridad,
          latitud: r.latitud,
          longitud: r.longitud,
          fechaCreacion: r.fechaCreacion,
          ultimaActualizacion: DateTime.now(),
          operativo: r.operativo,
          fotoUrl: r.fotoUrl,
        );
}

class _ReportesConServidor extends FakeReportesCiudadanoRepository {
  _ReportesConServidor(this._servidor);

  final _Servidor _servidor;

  @override
  Future<Result<Pagina<IncidenciaResumen>>> misReportes({EstadoIncidencia? estado, int pagina = 0}) async {
    final todos = await super.misReportes();
    if (todos case Ok(:final value)) {
      final filtrados =
          value.contenido.map(_servidor.aplicar).where((r) => estado == null || r.estado == estado).toList();
      return Result.ok(Pagina(contenido: filtrados, numero: 0, totalPaginas: 1));
    }
    return todos;
  }

  @override
  Future<Result<String>> confirmarResolucion(int id) async {
    _servidor.confirmaciones++;
    _servidor.cerradas.add(id);
    return super.confirmarResolucion(id);
  }
}

class _IncidenciasConServidor extends FakeIncidenciasRepository {
  _IncidenciasConServidor(this._servidor);

  final _Servidor _servidor;

  @override
  Future<Result<IncidenciaDetalle>> detalle(int id) async {
    final res = await super.detalle(id);
    if (res case Ok(value: final d)) {
      return Result.ok(
        IncidenciaDetalle(
          resumen: _servidor.aplicar(d.resumen),
          descripcion: d.descripcion,
          numReaperturas: d.numReaperturas,
          fechaResolucion: d.fechaResolucion,
          fotoReporteUrl: d.fotoReporteUrl,
          fotoSolucionUrl: d.fotoSolucionUrl,
          descripcionSolucion: d.descripcionSolucion,
          ciudadano: d.ciudadano,
          operativoAsignado: d.operativoAsignado,
          sinSensor: d.sinSensor,
        ),
      );
    }
    return res;
  }
}

void main() {
  // Conecta el motor de pruebas con el emulador: es OBLIGATORIO
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('HU-13: Confirmar resolución de punta a punta', () {
    testWidgets(
      'B1 filtrado en Resuelta → C2 → Confirmar resolución → Cerrada, y al volver ya no aparece en Resueltas',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        // pumpAndSettle no espera las demoras simuladas de los fakes (600–800 ms, a veces una tras otra,
        // como el login y luego la lista); se avanza el reloj en pasos cortos para que todas terminen
        Future<void> esperar() async {
          for (var i = 0; i < 6; i++) {
            await tester.pump(const Duration(milliseconds: 400));
          }
          await tester.pumpAndSettle();
        }

        final servidor = _Servidor();
        final auth = AuthRepositoryImpl(
          remote: FakeAuthRemoteDataSource(),
          session: SessionStorage(crearStorageEnMemoria()),
        );

        await tester.pumpWidget(
          FixFlowApp(
            authRepository: auth,
            reportesCiudadanoRepository: _ReportesConServidor(servidor),
            incidenciasRepository: _IncidenciasConServidor(servidor),
          ),
        );
        await tester.pumpAndSettle();

        // PASO 1: entrar como ciudadano
        await tester.enterText(find.byKey(const Key('login_correo')), 'ciudadano@fixflow.mx');
        await tester.enterText(find.byKey(const Key('login_password')), FakeAuthRemoteDataSource.passwordDemo);
        await tester.ensureVisible(find.byKey(const Key('login_entrar')));
        await tester.tap(find.byKey(const Key('login_entrar')));
        await esperar();
        expect(find.byType(MisReportesScreen), findsOneWidget);

        // PASO 2: filtrar por Resuelta en B1 y abrir la 000097
        // «Resuelta» también es el chip de estado de la tarjeta: se toca el de los filtros
        await tester.tap(
          find.descendant(of: find.byWidgetPredicate((w) => w is ChipsFiltro), matching: find.text('Resuelta')),
        );
        await esperar();
        await tester.tap(find.textContaining('000097'));
        await esperar();
        expect(find.byType(DetalleIncidenciaScreen), findsOneWidget);

        // PASO 3: en C2 está la pregunta y, al final, «Confirmar resolución» (CA-2, CA-3)
        final confirmar = find.byKey(const Key('detalle_confirmar_resolucion'));
        await tester.scrollUntilVisible(confirmar, 300);
        expect(find.text('¿Se solucionó el problema?'), findsOneWidget);
        await tester.tap(confirmar);
        await tester.pumpAndSettle();

        // PASO 4: la hoja pide confirmar; al aceptar se cierra el reporte y sale el texto del servidor
        expect(find.text('¿Confirmar resolución?'), findsOneWidget);
        await tester.tap(find.text('Confirmar resolución').last);
        await esperar();
        expect(servidor.confirmaciones, 1);
        expect(find.text('Solución confirmada; la incidencia quedó cerrada'), findsOneWidget);

        // PASO 5: C2 se recarga en Cerrada y ya no ofrece la acción
        expect(find.text('Cerrada'), findsWidgets);
        expect(find.byKey(const Key('detalle_confirmar_resolucion')), findsNothing);

        // PASO 6: al volver, B1 se recarga con el mismo filtro y la 000097 ya no está en Resueltas
        await tester.pageBack();
        await esperar();
        expect(find.byType(MisReportesScreen), findsOneWidget);
        expect(find.textContaining('000097'), findsNothing);
        expect(find.text('Sin reportes en este estado'), findsOneWidget);
      },
    );
  });
}
