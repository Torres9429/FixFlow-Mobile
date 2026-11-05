import 'package:dio/dio.dart';

import '../../core/result.dart';
import '../../domain/entities/estado_incidencia.dart';
import '../../domain/entities/incidencia_resumen.dart';
import '../../domain/entities/pagina.dart';
import '../../domain/entities/reporte_creado.dart';
import '../../domain/entities/reporte_nuevo.dart';
import '../../domain/repositories/reportes_ciudadano_repository.dart';
import '../datasources/remote/traducir_error.dart';
import '../models/incidencia_resumen_model.dart';
import '../models/reporte_creado_model.dart';

class ReportesCiudadanoRepositoryImpl implements ReportesCiudadanoRepository {
  ReportesCiudadanoRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<Result<Pagina<IncidenciaResumen>>> misReportes({EstadoIncidencia? estado, int pagina = 0}) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/incidencias/mias',
        queryParameters: {
          // El back todavía ignora `estado` aquí (contrato-api, cambios pendientes); se manda igual
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

  @override
  Future<Result<ReporteCreado>> crear(ReporteNuevo reporte, String fotoUrl) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/incidencias',
        data: {
          // El back espera el id numérico del tipo
          'tipoId': int.tryParse(reporte.tipo.id) ?? reporte.tipo.id,
          'descripcion': reporte.descripcion,
          'latitud': reporte.latitud,
          'longitud': reporte.longitud,
          'inclinacion': reporte.inclinacion,
          'fotoUrl': fotoUrl,
        },
      );
      return Result.ok(ReporteCreadoModel.fromJson(res.data!['result'] as Map<String, dynamic>));
    } catch (e) {
      return Result.error(traducirError(e));
    }
  }
}
