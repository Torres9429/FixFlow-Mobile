// Test tipo Unitarias: se prueba una clase o función sin pantalla y sin red real

import 'dart:async';

import 'package:fix_flow/domain/entities/accion_aviso.dart';
import 'package:fix_flow/domain/entities/aviso_push.dart';
import 'package:fix_flow/domain/entities/rol.dart';
import 'package:fix_flow/presentation/avisos/push_viewmodel.dart';
import 'package:fix_flow/presentation/avisos/ruta_aviso.dart';
import 'package:fix_flow/presentation/routing/rutas.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks.dart';

void main() {
  late MockPushRepository push;
  late StreamController<AvisoPush> tocados;
  late StreamController<AvisoPush> recibidos;

  const reabierta = AvisoPush(
    incidenciaId: 97,
    accion: AccionAviso.reapertura,
    titulo: 'Incidencia reabierta',
    mensaje: 'El ciudadano reabrió FX-2026-000097: sigue la fuga',
  );

  setUp(() {
    push = MockPushRepository();
    tocados = StreamController<AvisoPush>.broadcast();
    recibidos = StreamController<AvisoPush>.broadcast();
    when(() => push.tocados).thenAnswer((_) => tocados.stream);
    when(() => push.recibidos).thenAnswer((_) => recibidos.stream);
    when(() => push.avisoInicial()).thenAnswer((_) async => null);
  });

  tearDown(() async {
    await tocados.close();
    await recibidos.close();
  });

  group('HU-12: avisos push', () {
    test('Si un aviso abrió la app cerrada, se abre su incidencia una sola vez', () async {
      when(() => push.avisoInicial()).thenAnswer((_) async => reabierta);
      final vm = PushViewModel(pushRepository: push);

      await vm.iniciar();

      expect(vm.tomarPorAbrir()?.incidenciaId, 97);
      expect(vm.tomarPorAbrir(), isNull);
    });

    test('Tocar un aviso con la app en segundo plano lo deja listo para abrir', () async {
      final vm = PushViewModel(pushRepository: push);
      await vm.iniciar();

      tocados.add(reabierta);
      await Future<void>.delayed(Duration.zero);

      expect(vm.tomarPorAbrir(), reabierta);
    });

    test('Un aviso con la app abierta se muestra una vez y cuenta como nuevo', () async {
      final vm = PushViewModel(pushRepository: push);
      await vm.iniciar();

      recibidos.add(reabierta);
      await Future<void>.delayed(Duration.zero);

      expect(vm.nuevos, 1);
      expect(vm.tomarRecibido(), reabierta);
      expect(vm.tomarRecibido(), isNull);
    });

    test('Cada rol abre el detalle de su incidencia', () {
      expect(rutaDeAviso(Rol.ciudadano, 97, AccionAviso.reapertura), Rutas.detalleCiudadano(97));
      expect(rutaDeAviso(Rol.operativo, 97, AccionAviso.reapertura), Rutas.detalleOperativo(97));
      expect(rutaDeAviso(Rol.admin, 97, AccionAviso.reapertura), Rutas.detalleAdmin(97));
    });

    test('La acción que manda el back se traduce; una desconocida no truena', () {
      expect(AccionAviso.desde('REAPERTURA'), AccionAviso.reapertura);
      expect(AccionAviso.desde('cambio_estado'), AccionAviso.cambioEstado);
      expect(AccionAviso.desde(null), AccionAviso.otra);
    });
  });
}
