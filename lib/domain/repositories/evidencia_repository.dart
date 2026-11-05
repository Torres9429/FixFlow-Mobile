import '../../core/result.dart';

/// Fotos de evidencia en Cloudinary (RNF-05).
abstract interface class EvidenciaRepository {
  /// Comprime la foto (1600 px, calidad 80), la sube firmada y devuelve su `secure_url`.
  /// Si falla, devuelve una `FallaRed`.
  Future<Result<String>> subirFoto(String rutaFoto);
}
