import 'package:dio/dio.dart';

import '../../core/result.dart';
import '../../domain/entities/tipo_incidencia.dart';
import '../../domain/repositories/incidence_type_repository.dart';
import '../datasources/remote/traducir_error.dart';
import '../models/incidencia_resumen_model.dart';

class IncidenceTypeRepositoryImpl implements IncidenceTypeRepository {
  IncidenceTypeRepositoryImpl(this._dio);

  final Dio _dio;

  static const _admin = '/admin/tipos-incidencia';

  @override
  Future<Result<List<TipoIncidencia>>> obtenerTipos() => _lista('/tipos-incidencia');

  @override
  Future<Result<List<TipoIncidencia>>> catalogo() => _lista(_admin);

  @override
  Future<Result<TipoIncidencia>> crear(DatosTipo datos) async {
    try {
      final codigo = datos.codigo?.trim();
      final res = await _dio.post<Map<String, dynamic>>(
        _admin,
        data: {..._cuerpo(datos), 'codigo': (codigo == null || codigo.isEmpty) ? null : codigo},
      );
      return Result.ok(_tipoDesde(res.data!['result'] as Map<String, dynamic>));
    } catch (e) {
      return Result.error(traducirError(e));
    }
  }

  @override
  Future<Result<TipoIncidencia>> editar(String id, DatosTipo datos) async {
    try {
      final res = await _dio.put<Map<String, dynamic>>('$_admin/$id', data: _cuerpo(datos));
      return Result.ok(_tipoDesde(res.data!['result'] as Map<String, dynamic>));
    } catch (e) {
      return Result.error(traducirError(e));
    }
  }

  @override
  Future<Result<TipoIncidencia>> cambiarEstatus(String id, {required bool activo}) async {
    try {
      final res = await _dio.patch<Map<String, dynamic>>('$_admin/$id/estatus', data: {'activo': activo});
      return Result.ok(_tipoDesde(res.data!['result'] as Map<String, dynamic>));
    } catch (e) {
      return Result.error(traducirError(e));
    }
  }

  Future<Result<List<TipoIncidencia>>> _lista(String ruta) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(ruta);
      final tipos = (res.data!['result'] as List<dynamic>)
          .map((item) => _tipoDesde(item as Map<String, dynamic>))
          .toList(growable: false);
      return Result.ok(tipos);
    } catch (e) {
      return Result.error(traducirError(e));
    }
  }

  /// `{nombre, orientacion, prioridadBase}`; el `codigo` solo se manda al crear.
  Map<String, dynamic> _cuerpo(DatosTipo datos) => {
    'nombre': datos.nombre.trim(),
    'orientacion': switch (datos.orientacion) {
      OrientacionFoto.suelo => 'SUELO',
      OrientacionFoto.arriba => 'ARRIBA',
      OrientacionFoto.sinRestriccion => 'SIN_RESTRICCION',
    },
    'prioridadBase': IncidenciaResumenModel.codigoPrioridad(datos.prioridadBase),
  };

  /// `{id, codigo, nombre, orientacion, prioridadBase, estatus, anguloMin, anguloMax, incidencias}` (contrato-api, B2 y E10).
  TipoIncidencia _tipoDesde(Map<String, dynamic> j) => TipoIncidencia(
    id: (j['id'] as Object).toString(),
    nombre: j['nombre'] as String,
    codigo: j['codigo'] as String,
    orientacion: switch (j['orientacion']) {
      'SUELO' => OrientacionFoto.suelo,
      'ARRIBA' => OrientacionFoto.arriba,
      'SIN_RESTRICCION' => OrientacionFoto.sinRestriccion,
      final otro => throw FormatException('Orientación desconocida: $otro'),
    },
    prioridadBase: IncidenciaResumenModel.prioridadDesde(j['prioridadBase'] as String),
    activo: j['estatus'] as bool? ?? true,
    incidencias: (j['incidencias'] as num?)?.toInt(),
    anguloMin: (j['anguloMin'] as num?)?.toDouble(),
    anguloMax: (j['anguloMax'] as num?)?.toDouble(),
  );
}
