import 'package:dio/dio.dart';

import '../../core/result.dart';
import '../../domain/entities/estado_incidencia.dart';
import '../../domain/entities/incidencia_resumen.dart';
import '../../domain/entities/indicadores.dart';
import '../../domain/entities/operativo.dart';
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
      return Result.ok(
        IndicadoresModel.fromJson(res.data!['result'] as Map<String, dynamic>),
      );
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
          'estado': ?(estado == null
              ? null
              : IncidenciaResumenModel.codigoEstado(estado)),
          'prioridad': ?(prioridad == null
              ? null
              : IncidenciaResumenModel.codigoPrioridad(prioridad)),
          'page': pagina,
          'size': tamano,
        },
      );
      return Result.ok(
        IncidenciaResumenModel.paginaFromJson(
          res.data!['result'] as Map<String, dynamic>,
        ),
      );
    } catch (e) {
      return Result.error(traducirError(e));
    }
  }

  @override
  Future<Result<List<Operativo>>> operativosDisponibles() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/operativos',
        queryParameters: {'activos': true},
      );
      return Result.ok(
        _operativosFromJson(res.data!['result'] as List<dynamic>),
      );
    } catch (e) {
      return Result.error(traducirError(e));
    }
  }

  @override
  Future<Result<List<Operativo>>> listarOperativos() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/operativos',
        queryParameters: {'activos': false},
      );
      return Result.ok(
        _operativosFromJson(res.data!['result'] as List<dynamic>),
      );
    } catch (e) {
      return Result.error(traducirError(e));
    }
  }

  List<Operativo> _operativosFromJson(List<dynamic> result) => result
      .map((json) {
        final item = json as Map<String, dynamic>;
        return Operativo(
          id: (item['id'] as num).toInt(),
          nombre: item['nombre'] as String,
          apellidos: item['apellidos'] as String,
          correo: item['correo'] as String,
          activo: item['activo'] as bool,
          cargaActual: (item['cargaActual'] as num).toInt(),
        );
      })
      .toList(growable: false);

  @override
  Future<Result<void>> crearOperativo({
    required String nombre,
    required String apellidos,
    required String correo,
    required String passwordTemporal,
  }) async {
    try {
      await _dio.post<void>(
        '/admin/operativos',
        data: {
          'nombre': nombre,
          'apellidos': apellidos,
          'correo': correo,
          'passwordTemporal': passwordTemporal,
        },
      );
      return const Result.ok(null);
    } catch (e) {
      return Result.error(traducirError(e));
    }
  }

  @override
  Future<Result<void>> cambiarEstatusOperativo(
    int id, {
    required bool activo,
  }) async {
    try {
      await _dio.patch<void>(
        '/admin/operativos/$id/estatus',
        data: {'activo': activo},
      );
      return const Result.ok(null);
    } catch (e) {
      return Result.error(traducirError(e));
    }
  }

  @override
  Future<Result<void>> asignarIncidencia(
    int incidenciaId,
    int operativoId,
  ) async {
    try {
      await _dio.post<void>(
        '/incidencias/$incidenciaId/asignacion',
        data: {'operativoId': operativoId},
      );
      return const Result.ok(null);
    } catch (e) {
      return Result.error(traducirError(e));
    }
  }
}
