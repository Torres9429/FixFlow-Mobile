import 'package:dio/dio.dart';

import '../../core/result.dart';
import '../../domain/entities/tipo_incidencia.dart';
import '../../domain/repositories/incidence_type_repository.dart';
import '../datasources/remote/traducir_error.dart';

class IncidenceTypeRepositoryImpl implements IncidenceTypeRepository {
  IncidenceTypeRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<Result<List<TipoIncidencia>>> obtenerTipos() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/tipos-incidencia');
      final tipos = (res.data!['result'] as List<dynamic>)
          .map((item) => _tipoDesde(item as Map<String, dynamic>))
          .toList(growable: false);
      return Result.ok(tipos);
    } catch (e) {
      return Result.error(traducirError(e));
    }
  }

  /// `{id, codigo, nombre, orientacion, prioridadBase, anguloMin, anguloMax}` (contrato-api, B2).
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
  );
}
