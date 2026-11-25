import '../../../core/result.dart';
import '../../../domain/entities/accion_aviso.dart';
import '../../../domain/entities/aviso.dart';
import '../../../domain/entities/pagina.dart';
import '../../../domain/repositories/avisos_repository.dart';

/// Bandeja del modo mock con los avisos de design.md. No sabe el rol: muestra los de los 3.
class FakeAvisosRepository implements AvisosRepository {
  FakeAvisosRepository({List<Aviso>? avisos}) : _avisos = [...(avisos ?? _demo())];

  // Copia propia por instancia, sin estado static (cada prueba arranca limpia)
  final List<Aviso> _avisos;

  @override
  Future<Result<Pagina<Aviso>>> avisos({int pagina = 0}) async =>
      Result.ok(Pagina(contenido: List.unmodifiable(_avisos), numero: 0, totalPaginas: 1));

  @override
  Future<Result<int>> noLeidos() async => Result.ok(_avisos.where((a) => !a.leida).length);

  @override
  Future<Result<void>> marcarLeido(int id) async {
    final i = _avisos.indexWhere((a) => a.id == id);
    if (i >= 0) _avisos[i] = _avisos[i].leido();
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> marcarTodosLeidos() async {
    for (var i = 0; i < _avisos.length; i++) {
      _avisos[i] = _avisos[i].leido();
    }
    return const Result.ok(null);
  }

  static List<Aviso> _demo() {
    final ahora = DateTime.now();
    Aviso aviso(int id, String titulo, String mensaje, Duration hace, int incidencia, AccionAviso accion,
            {bool leida = false}) =>
        Aviso(
          id: id,
          titulo: titulo,
          mensaje: mensaje,
          leida: leida,
          fecha: ahora.subtract(hace),
          incidenciaId: incidencia,
          folio: 'FX-2026-${incidencia.toString().padLeft(6, '0')}',
          accion: accion,
        );
    return [
      aviso(6, 'Incidencia reabierta', 'El ciudadano reabrió FX-2026-000097: «La fuga sigue saliendo por la banqueta»',
          const Duration(minutes: 25), 97, AccionAviso.reapertura),
      aviso(5, 'Nueva incidencia asignada', 'Se te asignó la incidencia FX-2026-000131 (Bache)',
          const Duration(hours: 2), 131, AccionAviso.asignacion),
      aviso(4, 'Tu reporte fue resuelto', 'Revisa la solución de FX-2026-000097 y confírmala o reábrela',
          const Duration(hours: 5), 97, AccionAviso.solucion),
      aviso(3, 'Tu reporte cambió de estado', 'Tu reporte FX-2026-000123 ahora está En proceso',
          const Duration(days: 2), 123, AccionAviso.cambioEstado, leida: true),
      aviso(2, 'Tu reporte cambió de estado', 'Tu reporte FX-2026-000118 ahora está Asignada',
          const Duration(days: 4), 118, AccionAviso.asignacion, leida: true),
      aviso(1, 'Tu reporte cambió de estado', 'Tu reporte FX-2026-000142 ahora está Cerrada',
          const Duration(days: 12), 142, AccionAviso.cambioEstado, leida: true),
    ];
  }
}
