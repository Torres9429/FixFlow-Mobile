import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../../core/result.dart';
import '../../domain/repositories/evidencia_repository.dart';
import '../datasources/remote/traducir_error.dart';

/// Subida firmada desde la app (contrato-api, Fotos): el back firma, la app sube y el back solo guarda la URL.
class EvidenciaRepositoryImpl implements EvidenciaRepository {
  EvidenciaRepositoryImpl(this._api, {Dio? cloudinary}) : _cloudinary = cloudinary ?? Dio();

  /// El Dio del back, con JWT.
  final Dio _api;

  /// Dio aparte, sin interceptores: el JWT nunca debe llegar a Cloudinary.
  final Dio _cloudinary;

  @override
  Future<Result<String>> subirFoto(String rutaFoto) async {
    try {
      // 1. Firma del back (503 si Cloudinary no está configurado)
      final res = await _api.post<Map<String, dynamic>>('/evidencias/firma', data: {'tipo': 'REPORTE'});
      final firma = res.data!['result'] as Map<String, dynamic>;

      // 2. JPEG de 1600 px como máximo y calidad 80 (RNF-05)
      final bytes = await FlutterImageCompress.compressWithFile(rutaFoto, minWidth: 1600, minHeight: 1600, quality: 80);
      if (bytes == null) throw const FormatException('No se pudo comprimir la foto');

      // 3. Subida a Cloudinary con los mismos parámetros que se firmaron
      final subida = await _cloudinary.post<Map<String, dynamic>>(
        'https://api.cloudinary.com/v1_1/${firma['cloudName']}/image/upload',
        data: FormData.fromMap({
          'file': MultipartFile.fromBytes(bytes, filename: 'evidencia.jpg'),
          'api_key': firma['apiKey'],
          'timestamp': firma['timestamp'],
          'folder': firma['folder'],
          'signature': firma['signature'],
        }),
      );
      return Result.ok(subida.data!['secure_url'] as String);
    } catch (e) {
      return Result.error(traducirError(e));
    }
  }
}
