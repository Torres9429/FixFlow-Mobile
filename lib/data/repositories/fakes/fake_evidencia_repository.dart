import '../../../core/result.dart';
import '../../../domain/repositories/evidencia_repository.dart';

/// Subida simulada del modo mock: no sale a la red.
class FakeEvidenciaRepository implements EvidenciaRepository {
  @override
  Future<Result<String>> subirFoto(String rutaFoto) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return Result.ok('https://res.cloudinary.com/demo/fixflow/reportes/${DateTime.now().millisecondsSinceEpoch}.jpg');
  }
}
