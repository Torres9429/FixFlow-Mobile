import '../../../core/result.dart';
import '../../../domain/entities/estado_incidencia.dart';
import '../../../domain/entities/incidencia_resumen.dart';
import '../../../domain/entities/pagina.dart';
import '../../../domain/repositories/operativo_repository.dart';
import 'datos_demo.dart';

/// Asignadas en el modo mock: las 4 de Luis de design.md §9.
class FakeOperativoRepository implements OperativoRepository {
  static const _activos = {
    EstadoIncidencia.asignada,
    EstadoIncidencia.enProceso,
    EstadoIncidencia.reabierta,
  };

  final _items = List.of(DatosDemo.asignadasLuis);

  @override
  Future<Result<Pagina<IncidenciaResumen>>> asignadas({EstadoIncidencia? estado, int pagina = 0}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final filtradas = _items
        .where((i) => estado == null ? _activos.contains(i.estado) : i.estado == estado)
        .toList();
    return Result.ok(Pagina(contenido: filtradas, numero: 0, totalPaginas: 1));
  }

  @override
  Future<Result<void>> iniciarAtencion(int incidenciaId) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _actualizarEstado(incidenciaId, EstadoIncidencia.enProceso);
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> registrarSolucion({
    required int incidenciaId,
    required String descripcion,
    required String fotoUrl,
    double? latitud,
    double? longitud,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _actualizarEstado(incidenciaId, EstadoIncidencia.resuelta);
    return const Result.ok(null);
  }

  void _actualizarEstado(int incidenciaId, EstadoIncidencia nuevoEstado) {
    final idx = _items.indexWhere((i) => i.id == incidenciaId);
    if (idx == -1) return;
    final actual = _items[idx];
    _items[idx] = IncidenciaResumen(
      id: actual.id,
      folio: actual.folio,
      tipo: actual.tipo,
      tipoCodigo: actual.tipoCodigo,
      estado: nuevoEstado,
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
}
