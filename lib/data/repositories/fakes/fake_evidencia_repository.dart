import '../../../core/result.dart';
import '../../../domain/repositories/evidencia_repository.dart';

/// Subida simulada del modo mock: no sale a la red.
class FakeEvidenciaRepository implements EvidenciaRepository {
  @override
  Future<Result<String>> subirFoto(
    String rutaFoto, {
    TipoEvidencia tipo = TipoEvidencia.reporte,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final carpeta = tipo == TipoEvidencia.solucion ? 'soluciones' : 'reportes';
    return Result.ok('https://res.cloudinary.com/demo/fixflow/$carpeta/${DateTime.now().millisecondsSinceEpoch}.jpg');
  }
}
