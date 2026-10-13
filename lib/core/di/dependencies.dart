import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../data/datasources/local/session_storage.dart';
import '../../data/datasources/remote/api_client.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/remote/fake_auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../config/app_config.dart';

/// Lo que la app recibe ya armado. Solo este archivo conoce las clases de `data/`.
class Dependencias {
  const Dependencias({required this.authRepository});

  final AuthRepository authRepository;
}

Dependencias crearDependencias() {
  final session = SessionStorage(const FlutterSecureStorage());
  final api = ApiClient(session: session);

  // En modo mock solo cambia la fuente remota; repositorio y token son los reales
  final authRemote = AppConfig.usarMocks ? FakeAuthRemoteDataSource() : AuthRemoteDataSource(api.dio);

  return Dependencias(
    authRepository: AuthRepositoryImpl(remote: authRemote, session: session),
  );
}
