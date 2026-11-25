// Test tipo Unitarias: se prueba una clase o función sin pantalla y sin red real

import 'package:fix_flow/core/result.dart';
import 'package:fix_flow/data/repositories/fakes/fake_avisos_repository.dart';
import 'package:fix_flow/domain/entities/accion_aviso.dart';
import 'package:fix_flow/domain/entities/aviso.dart';
import 'package:fix_flow/domain/entities/pagina.dart';
import 'package:fix_flow/domain/errors/falla_red.dart';
import 'package:fix_flow/presentation/avisos/avisos_viewmodel.dart';
import 'package:fix_flow/presentation/avisos/contador_avisos_viewmodel.dart';
import 'package:fix_flow/presentation/core/estado_consulta.dart';
import 'package:fix_flow/presentation/core/formato_fecha.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks.dart';

void main() {
  // Martes 24 nov 2026, 10:00
  final ahora = DateTime(2026, 11, 24, 10);

  Aviso aviso(int id, Duration hace, {bool leida = false}) => Aviso(
    id: id,
    titulo: 'Nueva incidencia asignada',
    mensaje: 'Se te asignó la incidencia FX-2026-000131 (Bache)',
    leida: leida,
    fecha: ahora.subtract(hace),
    incidenciaId: 131,
    folio: 'FX-2026-000131',
    accion: AccionAviso.asignacion,
  );

  group('HU-12: bandeja de avisos (C1, D6, E7)', () {
    test('Agrupa en Hoy, Esta semana y Anteriores, sin grupos vacíos', () async {
      final vm = AvisosViewModel(
        avisosRepository: FakeAvisosRepository(
          avisos: [aviso(3, const Duration(hours: 2)), aviso(2, const Duration(days: 3)), aviso(1, const Duration(days: 20))],
        ),
        ahora: () => ahora,
      );

      await vm.cargar();

      expect(vm.grupos.map((g) => g.$1), ['Hoy', 'Esta semana', 'Anteriores']);
      expect(vm.grupos.first.$2.single.id, 3);
    });

    test('Tocar un aviso lo deja leído aquí y en el contador del shell', () async {
      final repo = FakeAvisosRepository(avisos: [aviso(1, const Duration(minutes: 5)), aviso(2, const Duration(hours: 1))]);
      final vm = AvisosViewModel(avisosRepository: repo, ahora: () => ahora);
      final contador = ContadorAvisosViewModel(avisosRepository: repo);
      await vm.cargar();
      await contador.cargar();
      expect(contador.noLeidos, 2);

      await vm.marcarLeido(vm.avisos.first);
      await contador.cargar();

      expect(vm.avisos.first.leida, isTrue);
      expect(contador.noLeidos, 1);
      expect(contador.hayNoLeidos, isTrue);
    });

    test('Marcar todo como leído apaga el punto; si el back falla, no cambia nada', () async {
      final vm = AvisosViewModel(
        avisosRepository: FakeAvisosRepository(avisos: [aviso(1, const Duration(minutes: 5))]),
        ahora: () => ahora,
      );
      await vm.cargar();

      await vm.marcarTodos();
      expect(vm.hayNoLeidos, isFalse);

      final mock = MockAvisosRepository();
      when(() => mock.avisos()).thenAnswer((_) async => Result.ok(_pagina([aviso(1, Duration.zero)])));
      when(() => mock.marcarTodosLeidos()).thenAnswer((_) async => const Result.error(SinConexion()));
      final conFalla = AvisosViewModel(avisosRepository: mock, ahora: () => ahora);
      await conFalla.cargar();

      final res = await conFalla.marcarTodos();

      expect(res, isA<Error<void>>());
      expect(conFalla.hayNoLeidos, isTrue);
    });

    test('Si el contador del shell sube (llegó un push), la bandeja se recarga', () async {
      final mock = MockAvisosRepository();
      when(() => mock.avisos()).thenAnswer((_) async => Result.ok(_pagina([aviso(1, Duration.zero)])));
      final vm = AvisosViewModel(avisosRepository: mock, ahora: () => ahora);
      await vm.cargar();

      vm.sincronizar(1); // primer valor: solo se anota
      vm.sincronizar(1);
      verify(() => mock.avisos()).called(1);

      vm.sincronizar(2);
      await Future<void>.delayed(Duration.zero);
      verify(() => mock.avisos()).called(1);
      expect(vm.estado, isA<Listo<List<Aviso>>>());
    });

    test('La meta dice hace cuánto llegó', () {
      expect(haceCuanto(ahora.subtract(const Duration(seconds: 20)), ahora: ahora), 'ahora');
      expect(haceCuanto(ahora.subtract(const Duration(minutes: 5)), ahora: ahora), 'hace 5 min');
      expect(haceCuanto(ahora.subtract(const Duration(hours: 2)), ahora: ahora), 'hace 2 h');
      expect(haceCuanto(ahora.subtract(const Duration(days: 1)), ahora: ahora), 'ayer');
      expect(haceCuanto(ahora.subtract(const Duration(days: 3)), ahora: ahora), 'hace 3 días');
      expect(haceCuanto(DateTime(2026, 10, 30, 9), ahora: ahora), '30 oct');
    });
  });
}

Pagina<Aviso> _pagina(List<Aviso> avisos) => Pagina(contenido: avisos, numero: 0, totalPaginas: 1);
