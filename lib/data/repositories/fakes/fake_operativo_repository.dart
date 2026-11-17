import '../../../core/result.dart';
import '../../../domain/entities/estado_incidencia.dart';
import '../../../domain/entities/incidencia_resumen.dart';
import '../../../domain/entities/pagina.dart';
import '../../../domain/repositories/operativo_repository.dart';
import 'datos_demo.dart';
import 'fake_incidencias_repository.dart';

/// Asignadas en el modo mock: las 4 de Luis de design.md §9.
class FakeOperativoRepository implements OperativoRepository {
  FakeOperativoRepository({List<IncidenciaResumen>? iniciales})
      : _items = iniciales ?? _itemsCompartidos;

  static final List<IncidenciaResumen> _itemsCompartidos = List.of(DatosDemo.asignadasLuis);

  final List<IncidenciaResumen> _items;

  static void registrarAsignacion(IncidenciaResumen incidencia) {
    _itemsCompartidos.removeWhere((i) => i.id == incidencia.id);
    _itemsCompartidos.insert(0, incidencia);
  }

  @override
  Future<Result<Pagina<IncidenciaResumen>>> asignadas({EstadoIncidencia? estado, int pagina = 0}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final filtradas = _items.where((i) => estado == null || i.estado == estado).toList();
    return Result.ok(Pagina(contenido: filtradas, numero: 0, totalPaginas: 1));
  }

  @override
  Future<Result<void>> iniciarAtencion(int incidenciaId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    FakeIncidenciasRepository.estadosSobrescritos[incidenciaId] = EstadoIncidencia.enProceso;
    final idx = _items.indexWhere((i) => i.id == incidenciaId);
    if (idx != -1) {
      final actual = _items[idx];
      _items[idx] = IncidenciaResumen(
        id: actual.id,
        folio: actual.folio,
        tipo: actual.tipo,
        tipoCodigo: actual.tipoCodigo,
        estado: EstadoIncidencia.enProceso,
        prioridad: actual.prioridad,
        motivoPrioridad: actual.motivoPrioridad,
        latitud: actual.latitud,
        longitud: actual.longitud,
        fechaCreacion: actual.fechaCreacion,
        ultimaActualizacion: DateTime.now(),
        operativo: actual.operativo,
        fotoUrl: actual.fotoUrl,
      );
    }
    return const Result.ok(null);
  }
}
