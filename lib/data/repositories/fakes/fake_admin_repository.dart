import '../../../core/result.dart';
import '../../../domain/entities/estado_incidencia.dart';
import '../../../domain/entities/incidencia_resumen.dart';
import '../../../domain/entities/indicadores.dart';
import '../../../domain/entities/pagina.dart';
import '../../../domain/entities/prioridad.dart';
import '../../../domain/repositories/admin_repository.dart';
import 'datos_demo.dart';

/// Panel del admin en el modo mock, con las cifras de design.md §9.
class FakeAdminRepository implements AdminRepository {
  @override
  Future<Result<Indicadores>> indicadores() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return const Result.ok(
      Indicadores(
        registradas: 128,
        pendientes: 23,
        enAtencion: 8,
        atendidas: 97,
        porPrioridad: {Prioridad.alta: 12, Prioridad.media: 58, Prioridad.baja: 58},
        resolucionPromedioHoras: 77,
        resolucionMaxHoras: 312,
      ),
    );
  }

  @override
  Future<Result<Pagina<IncidenciaResumen>>> incidencias({
    EstadoIncidencia? estado,
    Prioridad? prioridad,
    int pagina = 0,
    int tamano = 20,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final filtradas = DatosDemo.municipio
        .where((i) => (estado == null || i.estado == estado) && (prioridad == null || i.prioridad == prioridad))
        .take(tamano)
        .toList();
    return Result.ok(Pagina(contenido: filtradas, numero: 0, totalPaginas: 1));
  }
}
