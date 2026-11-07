import 'package:dio/dio.dart';

import '../../core/result.dart';
import '../../domain/entities/evento_historial.dart';
import '../../domain/entities/incidencia_detalle.dart';
import '../../domain/repositories/incidencias_repository.dart';
import '../datasources/remote/traducir_error.dart';
import '../models/evento_historial_model.dart';
import '../models/incidencia_detalle_model.dart';

class IncidenciasRepositoryImpl implements IncidenciasRepository {
  IncidenciasRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<Result<IncidenciaDetalle>> detalle(int id) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/incidencias/$id');
      return Result.ok(IncidenciaDetalleModel.fromJson(res.data!['result'] as Map<String, dynamic>));
    } catch (e) {
      return Result.error(traducirError(e));
    }
  }

  @override
  Future<Result<List<EventoHistorial>>> historial(int id) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/incidencias/$id/historial');
      return Result.ok(EventoHistorialModel.listaFromJson(res.data!['result'] as List<dynamic>));
    } catch (e) {
      return Result.error(traducirError(e));
    }
  }
}
