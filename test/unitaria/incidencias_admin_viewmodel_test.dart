// Test tipo Unitarias: se prueba una clase o función sin pantalla y sin red real

import 'package:fix_flow/core/result.dart';
import 'package:fix_flow/domain/entities/estado_incidencia.dart';
import 'package:fix_flow/domain/entities/incidencia_resumen.dart';
import 'package:fix_flow/domain/entities/pagina.dart';
import 'package:fix_flow/domain/entities/prioridad.dart';
import 'package:fix_flow/domain/entities/tipo_incidencia.dart';
import 'package:fix_flow/domain/errors/falla_red.dart';
import 'package:fix_flow/presentation/admin/incidencias/incidencias_admin_viewmodel.dart';
import 'package:fix_flow/presentation/core/estado_consulta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks.dart';

void main() {
  late MockAdminRepository mockAdmin;
  late MockIncidenceTypeRepository mockTipos;

  setUp(() {
    mockAdmin = MockAdminRepository();
    mockTipos = MockIncidenceTypeRepository();
    when(() => mockTipos.obtenerTipos()).thenAnswer((_) async => const Result.ok(<TipoIncidencia>[]));
  });

  IncidenciaResumen crearIncidencia({required int id, required String folio}) => IncidenciaResumen(
        id: id,
        folio: folio,
        tipo: 'Bache',
        tipoCodigo: 'BACHE',
        estado: EstadoIncidencia.pendiente,
        prioridad: Prioridad.alta,
        motivoPrioridad: 'Prioridad alta',
        latitud: 18.92,
        longitud: -99.23,
        fechaCreacion: DateTime(2026, 11, 1),
        ultimaActualizacion: DateTime(2026, 11, 2),
      );

  group('HU-17: Visualizar incidencias municipales', () {
    test('Carga de primera página y actualización de estado en VM (CA-1)', () async {
      final i1 = crearIncidencia(id: 1, folio: 'FX-2026-000001');
      when(() => mockAdmin.incidencias(
            estado: any(named: 'estado'),
            prioridad: any(named: 'prioridad'),
            tipoId: any(named: 'tipoId'),
            q: any(named: 'q'),
            pagina: 0,
            tamano: any(named: 'tamano'),
          )).thenAnswer(
        (_) async => Result.ok(Pagina(contenido: [i1], numero: 0, totalPaginas: 2)),
      );

      final vm = IncidenciasAdminViewModel(
        adminRepository: mockAdmin,
        tiposRepository: mockTipos,
      );

      await vm.iniciar();

      expect(vm.estado, isA<Listo<List<IncidenciaResumen>>>());
      expect(vm.incidencias, hasLength(1));
      expect(vm.incidencias.first.folio, 'FX-2026-000001');
      expect(vm.esUltima, isFalse);
    });

    test('Concatenación de elementos en scroll infinito (cargarMas)', () async {
      final i1 = crearIncidencia(id: 1, folio: 'FX-2026-000001');
      final i2 = crearIncidencia(id: 2, folio: 'FX-2026-000002');

      when(() => mockAdmin.incidencias(
            estado: any(named: 'estado'),
            prioridad: any(named: 'prioridad'),
            tipoId: any(named: 'tipoId'),
            q: any(named: 'q'),
            pagina: 0,
            tamano: any(named: 'tamano'),
          )).thenAnswer(
        (_) async => Result.ok(Pagina(contenido: [i1], numero: 0, totalPaginas: 2)),
      );

      when(() => mockAdmin.incidencias(
            estado: any(named: 'estado'),
            prioridad: any(named: 'prioridad'),
            tipoId: any(named: 'tipoId'),
            q: any(named: 'q'),
            pagina: 1,
            tamano: any(named: 'tamano'),
          )).thenAnswer(
        (_) async => Result.ok(Pagina(contenido: [i2], numero: 1, totalPaginas: 2)),
      );

      final vm = IncidenciasAdminViewModel(
        adminRepository: mockAdmin,
        tiposRepository: mockTipos,
      );

      await vm.iniciar();
      expect(vm.incidencias, hasLength(1));

      await vm.cargarMas();
      expect(vm.incidencias, hasLength(2));
      expect(vm.incidencias[0].id, 1);
      expect(vm.incidencias[1].id, 2);
      expect(vm.esUltima, isTrue);
    });

    test('Manejo de fallo de red en listado municipal', () async {
      when(() => mockAdmin.incidencias(
            estado: any(named: 'estado'),
            prioridad: any(named: 'prioridad'),
            tipoId: any(named: 'tipoId'),
            q: any(named: 'q'),
            pagina: any(named: 'pagina'),
            tamano: any(named: 'tamano'),
          )).thenAnswer((_) async => const Result.error(SinConexion()));

      final vm = IncidenciasAdminViewModel(
        adminRepository: mockAdmin,
        tiposRepository: mockTipos,
      );

      await vm.iniciar();

      expect(vm.estado, isA<ConError<List<IncidenciaResumen>>>());
      expect((vm.estado as ConError<List<IncidenciaResumen>>).mensaje, contains('Revisa tu internet'));
    });
  });
}
