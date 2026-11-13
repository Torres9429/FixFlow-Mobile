import '../../../core/result.dart';
import '../../../domain/errors/auth_failure.dart';
import '../../../domain/errors/falla_red.dart';
import '../../models/login_response_model.dart';
import '../../models/perfil_model.dart';
import '../../models/registro_response_model.dart';
import 'auth_remote_datasource.dart';

typedef _UsuarioDemo = ({int id, String rol, String nombre, String apellidos, String password});

/// Back simulado para usar la app sin servidor (modo mock, ver `AppConfig.usarMocks`).
/// Todas las cuentas usan la contraseña `abc12345`.
class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  static const passwordDemo = 'abc12345';

  static final Map<String, _UsuarioDemo> _usuarios = {
    'ciudadano@fixflow.mx': (id: 1, rol: 'CIUDADANO', nombre: 'Ana', apellidos: 'López Ruiz', password: passwordDemo),
    'operativo@fixflow.mx': (id: 2, rol: 'OPERATIVO', nombre: 'Luis', apellidos: 'Ramírez', password: passwordDemo),
    'admin@fixflow.mx': (id: 3, rol: 'ADMIN', nombre: 'Marta', apellidos: 'Sánchez', password: passwordDemo),
  };

  String? _correoActual;

  @override
  Future<Result<LoginResponseModel>> login(String correo, String password) async {
    // Simula la latencia de la red para ver el estado de carga
    await Future<void>.delayed(const Duration(milliseconds: 800));

    final usuario = _usuarios[correo.toLowerCase()];
    if (usuario == null || password != usuario.password) {
      return const Result.error(CredencialesInvalidas());
    }
    _correoActual = correo.toLowerCase();
    return Result.ok(LoginResponseModel(
      token: 'token-falso-${usuario.rol.toLowerCase()}',
      refreshToken: 'refresh-falso',
      userId: usuario.id,
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
    _usuarios[correo.toLowerCase()] = (
      id: _usuarios.length + 1,
      rol: 'CIUDADANO',
      nombre: nombre,
      apellidos: apellidos,
      password: password,
    );

    return Result.ok(RegistroResponseModel(
      rol: 'CIUDADANO',
      nombre: nombre,
    ));
  }

  @override
  Future<void> logout(String refreshToken) async {
    _correoActual = null;
  }

  @override
  Future<Result<PerfilModel>> miPerfil() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final correo = _correoActual;
    final usuario = _usuarios[correo];
    if (correo == null || usuario == null) return const Result.error(SesionVencida());
    return Result.ok(_perfil(correo, usuario));
  }

  @override
  Future<Result<PerfilModel>> actualizarPerfil({required String nombre, required String apellidos}) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final correo = _correoActual;
    final usuario = _usuarios[correo];
    if (correo == null || usuario == null) return const Result.error(SesionVencida());
    final actualizado = (
      id: usuario.id,
      rol: usuario.rol,
      nombre: nombre,
      apellidos: apellidos,
      password: usuario.password,
    );
    _usuarios[correo] = actualizado;
    return Result.ok(_perfil(correo, actualizado));
  }

  @override
  Future<Result<String?>> cambiarPassword({required String actual, required String nueva}) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final correo = _correoActual;
    final usuario = _usuarios[correo];
    if (correo == null || usuario == null) return const Result.error(SesionVencida());
    if (actual != usuario.password) {
      return const Result.error(PeticionRechazada(400, 'La contraseña actual no es correcta'));
    }
    _usuarios[correo] = (
      id: usuario.id,
      rol: usuario.rol,
      nombre: usuario.nombre,
      apellidos: usuario.apellidos,
      password: nueva,
    );
    return const Result.ok('Contraseña actualizada');
  }

  PerfilModel _perfil(String correo, _UsuarioDemo usuario) => PerfilModel(
    id: usuario.id,
    nombre: usuario.nombre,
    apellidos: usuario.apellidos,
    correo: correo,
    rol: usuario.rol,
  );
}
