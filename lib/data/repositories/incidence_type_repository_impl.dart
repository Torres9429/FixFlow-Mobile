import 'package:dio/dio.dart';

import '../../domain/entities/tipo_incidencia.dart';
import '../../domain/repositories/incidence_type_repository.dart';

class IncidenceTypeRepositoryImpl implements IncidenceTypeRepository {
  IncidenceTypeRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<TipoIncidencia>> obtenerTipos() async {
    final response = await _dio.get<dynamic>('/tipos-incidencia');
    final raw = response.data;
    final data = raw is Map<String, dynamic> ? raw['result'] : raw;
    if (data is! List<dynamic>) {
      throw const FormatException('El servidor no devolvió tipos de incidencia.');
    }

    return data.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Tipo de incidencia inválido.');
      }
      final id = item['id']?.toString();
      final nombre = item['nombre']?.toString() ?? item['name']?.toString();
      if (id == null || nombre == null || nombre.trim().isEmpty) {
        throw const FormatException('Tipo de incidencia incompleto.');
      }
      return TipoIncidencia(id: id, nombre: nombre);
    }).toList(growable: false);
  }
}
