import '../../../domain/entities/aviso_push.dart';
import '../../../domain/repositories/push_repository.dart';

/// Modo mock, pruebas o Firebase sin configurar: no hay push, solo la bandeja.
class FakePushRepository implements PushRepository {
  @override
  Future<void> activar() async {}

  @override
  Future<void> desactivar() async {}

  @override
  Stream<AvisoPush> get recibidos => const Stream.empty();

  @override
  Stream<AvisoPush> get tocados => const Stream.empty();

  @override
  Future<AvisoPush?> avisoInicial() async => null;
}
