// Test tipo Unitaria: se prueba una parte del código sola, con sus dependencias simuladas

import 'package:fix_flow/core/result.dart';
import 'package:fix_flow/domain/entities/coordenada.dart';
import 'package:fix_flow/domain/entities/prioridad.dart';
import 'package:fix_flow/domain/entities/tipo_incidencia.dart';
import 'package:fix_flow/domain/errors/falla_red.dart';
import 'package:fix_flow/presentation/core/estado_consulta.dart';
import 'package:fix_flow/presentation/reporte/camara/resultado_captura.dart';
import 'package:fix_flow/presentation/reporte/nuevo_reporte_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks.dart';

void main() {
  group('HU-03 / B2: NuevoReporteViewModel', () {
    late MockIncidenceTypeRepository tipos;
    late MockUbicacionRepository ubicacion;
    late MockInclinacionRepository inclinacion;

    const bache = TipoIncidencia(
      id: '1',
      nombre: 'Bache',
      codigo: 'BACHE',
      orientacion: OrientacionFoto.suelo,
      prioridadBase: Prioridad.media,
      anguloMin: 45,
      anguloMax: 90,
    );
    final captura = ResultadoCaptura(rutaFoto: '/tmp/bache.jpg', inclinacion: 62, capturadaEn: DateTime(2026, 11, 20));

    setUp(() {
      tipos = MockIncidenceTypeRepository();
      ubicacion = MockUbicacionRepository();
      inclinacion = MockInclinacionRepository();
      when(() => tipos.obtenerTipos()).thenAnswer((_) async => const Result.ok([bache]));
      when(() => ubicacion.posicionActual()).thenAnswer((_) async => const Coordenada(18.92, -99.23, precision: 5));
      when(() => inclinacion.sensorDisponible()).thenAnswer((_) async => true);
      when(() => inclinacion.leerInclinacion()).thenAnswer((_) async => 50);
    });

    NuevoReporteViewModel crearVm() => NuevoReporteViewModel(
      tiposRepository: tipos,
      ubicacionRepository: ubicacion,
      inclinacionRepository: inclinacion,
    );

    test('Al iniciar carga los tipos, el GPS y revisa el sensor; si los tipos fallan queda el error', () async {
      final vm = crearVm();
      await vm.iniciar();
      expect(vm.tipos, isA<Listo<List<TipoIncidencia>>>());
      expect(vm.posicion?.precision, 5);
      expect(vm.sinSensor, isFalse);

      when(() => tipos.obtenerTipos()).thenAnswer((_) async => const Result.error(SinConexion()));
      await vm.cargarTipos();
      expect(vm.tipos, isA<ConError<List<TipoIncidencia>>>());
    });

    test('Sin GPS no deja continuar y vuelve a pedir la ubicación (HU-05, CA-5)', () async {
      when(() => ubicacion.posicionActual()).thenAnswer((_) async => null);
      final vm = crearVm();
      await vm.iniciar();

      expect(vm.errorUbicacion, isNotNull);
      expect(vm.motivoSinUbicacion(), 'La ubicación GPS es obligatoria para enviar el reporte. Actívala e intenta de nuevo.');
      // Una en iniciar() y otra al intentar continuar
      verify(() => ubicacion.posicionActual()).called(2);
    });

    test('Con sensor el reporte lleva la inclinación de la captura; sin sensor va en null y marcado (RN-11)', () async {
      final vm = crearVm();
      await vm.iniciar();
      vm
        ..elegirTipo(bache)
        ..guardarCaptura(captura);
      final conSensor = await vm.armarReporte('  Bache en la esquina  ');
      expect(conSensor.inclinacion, 62);
      expect(conSensor.sinSensor, isFalse);
      expect(conSensor.descripcion, 'Bache en la esquina');

      when(() => inclinacion.sensorDisponible()).thenAnswer((_) async => false);
      final sinSensorVm = crearVm();
      await sinSensorVm.iniciar();
      sinSensorVm
        ..elegirTipo(bache)
        ..guardarCaptura(ResultadoCaptura(rutaFoto: '/tmp/b.jpg', inclinacion: null, capturadaEn: DateTime(2026)));
      final sinSensor = await sinSensorVm.armarReporte('Bache');
      expect(sinSensor.inclinacion, isNull);
      expect(sinSensor.sinSensor, isTrue);
      verifyNever(() => inclinacion.leerInclinacion());
    });
  });
}
