import '../../../core/result.dart';
import '../../../domain/errors/auth_failure.dart';
import '../../models/login_response_model.dart';
import '../../models/registro_response_model.dart';
import 'auth_remote_datasource.dart';

/// Back simulado para usar la app sin servidor (modo mock, ver `AppConfig.usarMocks`).
/// Todas las cuentas usan la contraseña `abc12345`.
class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  static const passwordDemo = 'abc12345';

  static final _usuarios = {
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

  @override
  Future<Result<RegistroResponseModel>> registro({
    required String nombre,
    required String apellidos,
    required String correo,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));

    // Simula correo duplicado si ya existe en los usuarios de prueba
    if (_usuarios.containsKey(correo.toLowerCase())) {
      return const Result.error(CorreoDuplicado());
    }

    // Registra al usuario en memoria para que pueda iniciar sesión después
    _usuarios[correo.toLowerCase()] = (rol: 'CIUDADANO', nombre: nombre);

    return Result.ok(RegistroResponseModel(
      token: 'token-falso-ciudadano',
      rol: 'CIUDADANO',
      nombre: nombre,
    ));
  }
}

