import '../../core/result.dart';

/// Tipo de evidencia que se sube a Cloudinary (contrato-api, Fotos).
enum TipoEvidencia { reporte, solucion }

/// Fotos de evidencia en Cloudinary (RNF-05).
abstract interface class EvidenciaRepository {
  /// Comprime la foto (1600 px, calidad 80), la sube firmada y devuelve su `secure_url`.
  /// Si falla, devuelve una `FallaRed`.
  Future<Result<String>> subirFoto(
    String rutaFoto, {
    TipoEvidencia tipo = TipoEvidencia.reporte,
  });
}
