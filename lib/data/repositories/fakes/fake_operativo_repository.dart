import '../../../core/result.dart';
import '../../../domain/entities/estado_incidencia.dart';
import '../../../domain/entities/incidencia_resumen.dart';
import '../../../domain/entities/pagina.dart';
import '../../../domain/repositories/operativo_repository.dart';
import 'datos_demo.dart';

/// Asignadas en el modo mock: las 4 de Luis de design.md §9.
class FakeOperativoRepository implements OperativoRepository {
  @override
  Future<Result<Pagina<IncidenciaResumen>>> asignadas({EstadoIncidencia? estado, int pagina = 0}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final filtradas = DatosDemo.asignadasLuis.where((i) => estado == null || i.estado == estado).toList();
    return Result.ok(Pagina(contenido: filtradas, numero: 0, totalPaginas: 1));
  }
}
