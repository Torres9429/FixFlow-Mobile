import 'package:dio/dio.dart';

import '../../core/result.dart';
import '../../domain/entities/estado_incidencia.dart';
import '../../domain/entities/incidencia_resumen.dart';
import '../../domain/entities/pagina.dart';
import '../../domain/repositories/operativo_repository.dart';
import '../datasources/remote/traducir_error.dart';
import '../models/incidencia_resumen_model.dart';

class OperativoRepositoryImpl implements OperativoRepository {
  OperativoRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<Result<Pagina<IncidenciaResumen>>> asignadas({EstadoIncidencia? estado, int pagina = 0}) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/operativo/incidencias',
        queryParameters: {
          'estado': ?(estado == null ? null : IncidenciaResumenModel.codigoEstado(estado)),
          'page': pagina,
          'size': 20,
        },
      );
      return Result.ok(IncidenciaResumenModel.paginaFromJson(res.data!['result'] as Map<String, dynamic>));
    } catch (e) {
      return Result.error(traducirError(e));
    }
  }
}
