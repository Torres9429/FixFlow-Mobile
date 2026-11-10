import '../../core/result.dart';
import '../entities/evento_historial.dart';
import '../entities/incidencia_detalle.dart';

/// Consultas de una incidencia que comparten los 3 roles. El back decide qué datos ve cada uno.
abstract interface class IncidenciasRepository {
  /// `GET /incidencias/{id}` (HU-11). Si falla, devuelve una `FallaRed`.
  Future<Result<IncidenciaDetalle>> detalle(int id);

  /// `GET /incidencias/{id}/historial` (HU-22), del más antiguo al más reciente.
  Future<Result<List<EventoHistorial>>> historial(int id);
}
