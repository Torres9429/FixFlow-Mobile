import '../../../core/result.dart';
import '../../../domain/errors/auth_failure.dart';
import '../../../domain/errors/falla_red.dart';
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
  static final _contrasenas = <String, String>{
    for (final correo in _usuarios.keys) correo: passwordDemo,
  };
  static String? _correoActual;

  @override
  Future<Result<LoginResponseModel>> login(
    String correo,
    String password,
  ) async {
    // Simula la latencia de la red para ver el estado de carga
    await Future<void>.delayed(const Duration(milliseconds: 800));

    final usuario = _usuarios[correo.toLowerCase()];
    if (usuario == null || password != _contrasenas[correo.toLowerCase()]) {
      return const Result.error(CredencialesInvalidas());
    }
    _correoActual = correo.toLowerCase();
    return Result.ok(
      LoginResponseModel(
        token: 'token-falso-${usuario.rol.toLowerCase()}',
        refreshToken: 'refresh-falso',
        userId: 1,
        rol: usuario.rol,
        nombre: usuario.nombre,
      ),
    );
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
    _contrasenas[correo.toLowerCase()] = password;

    return Result.ok(RegistroResponseModel(rol: 'CIUDADANO', nombre: nombre));
  }

  @override
  Future<Result<void>> cambiarPassword({
    required String actual,
    required String nueva,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final correo = _correoActual;
    if (correo == null || _contrasenas[correo] != actual) {
      return const Result.error(CredencialesInvalidas());
    }
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$').hasMatch(nueva)) {
      return const Result.error(
        PeticionRechazada(
          400,
          'La contraseña debe tener al menos 8 caracteres, con letras y números',
        ),
      );
    }
    if (nueva == actual) {
      return const Result.error(
        PeticionRechazada(
          400,
          'La nueva contraseña debe ser distinta de la actual',
        ),
      );
    }
    _contrasenas[correo] = nueva;
    return const Result.ok(null);
  }

  @override
  Future<void> logout(String refreshToken) async {}
}
