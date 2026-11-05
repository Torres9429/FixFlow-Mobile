import 'package:dio/dio.dart';

import '../../core/result.dart';
import '../../domain/entities/estado_incidencia.dart';
import '../../domain/entities/incidencia_resumen.dart';
import '../../domain/entities/indicadores.dart';
import '../../domain/entities/pagina.dart';
import '../../domain/entities/prioridad.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/remote/traducir_error.dart';
import '../models/incidencia_resumen_model.dart';
import '../models/indicadores_model.dart';

class AdminRepositoryImpl implements AdminRepository {
  AdminRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<Result<Indicadores>> indicadores() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/admin/indicadores');
      return Result.ok(IndicadoresModel.fromJson(res.data!['result'] as Map<String, dynamic>));
    } catch (e) {
      return Result.error(traducirError(e));
    }
  }

  @override
  Future<Result<Pagina<IncidenciaResumen>>> incidencias({
    EstadoIncidencia? estado,
    Prioridad? prioridad,
    int pagina = 0,
    int tamano = 20,
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/admin/incidencias',
        queryParameters: {
          'estado': ?(estado == null ? null : IncidenciaResumenModel.codigoEstado(estado)),
          'prioridad': ?(prioridad == null ? null : IncidenciaResumenModel.codigoPrioridad(prioridad)),
          'page': pagina,
          'size': tamano,
        },
      );
      return Result.ok(IncidenciaResumenModel.paginaFromJson(res.data!['result'] as Map<String, dynamic>));
    } catch (e) {
      return Result.error(traducirError(e));
    }
  }
}
