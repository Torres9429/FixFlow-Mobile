import '../../../core/result.dart';
import '../../../domain/errors/auth_failure.dart';
import '../../models/login_response_model.dart';
import 'auth_remote_datasource.dart';

/// Back simulado para usar la app sin servidor (modo mock, ver `AppConfig.usarMocks`).
/// Todas las cuentas usan la contraseña `abc12345`.
class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  static const passwordDemo = 'abc12345';

  static const _usuarios = {
    'ciudadano@fixflow.mx': (rol: 'CIUDADANO', nombre: 'Ana'),
    'operativo@fixflow.mx': (rol: 'OPERATIVO', nombre: 'Luis'),
    'admin@fixflow.mx': (rol: 'ADMIN', nombre: 'Marta'),
  };

  @override
  Future<Result<LoginResponseModel>> login(String correo, String password) async {
    // Simula la latencia de la red para ver el estado de carga
    await Future<void>.delayed(const Duration(milliseconds: 800));

    final usuario = _usuarios[correo.toLowerCase()];
    if (usuario == null || password != passwordDemo) {
      return const Result.error(CredencialesInvalidas());
    }
    return Result.ok(LoginResponseModel(
      token: 'token-falso-${usuario.rol.toLowerCase()}',
      rol: usuario.rol,
      nombre: usuario.nombre,
    ));
  }
}
