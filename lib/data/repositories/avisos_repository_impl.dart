import 'package:dio/dio.dart';

import '../../core/result.dart';
import '../../domain/entities/aviso.dart';
import '../../domain/entities/pagina.dart';
import '../../domain/repositories/avisos_repository.dart';
import '../datasources/remote/traducir_error.dart';
import '../models/aviso_model.dart';

class AvisosRepositoryImpl implements AvisosRepository {
  AvisosRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<Result<Pagina<Aviso>>> avisos({int pagina = 0}) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/notificaciones',
        queryParameters: {'page': pagina, 'size': 20},
      );
      return Result.ok(AvisoModel.paginaFromJson(res.data!['result'] as Map<String, dynamic>));
    } catch (e) {
      return Result.error(traducirError(e));
    }
  }

  @override
  Future<Result<int>> noLeidos() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/notificaciones/no-leidas');
      final result = res.data!['result'] as Map<String, dynamic>;
      return Result.ok((result['total'] as num).toInt());
    } catch (e) {
      return Result.error(traducirError(e));
    }
  }

  @override
  Future<Result<void>> marcarLeido(int id) async {
    try {
      await _dio.patch<Map<String, dynamic>>('/notificaciones/$id/leida');
      return const Result.ok(null);
    } catch (e) {
      return Result.error(traducirError(e));
    }
  }

  @override
  Future<Result<void>> marcarTodosLeidos() async {
    try {
      await _dio.patch<Map<String, dynamic>>('/notificaciones/leidas');
      return const Result.ok(null);
    } catch (e) {
      return Result.error(traducirError(e));
    }
  }
}
