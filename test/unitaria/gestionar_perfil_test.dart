import 'package:dio/dio.dart';
import 'package:fix_flow/core/result.dart';
import 'package:fix_flow/data/datasources/local/session_storage.dart';
import 'package:fix_flow/data/datasources/remote/auth_remote_datasource.dart';
import 'package:fix_flow/data/datasources/remote/fake_auth_remote_datasource.dart';
import 'package:fix_flow/data/models/perfil_model.dart';
import 'package:fix_flow/data/repositories/auth_repository_impl.dart';
import 'package:fix_flow/domain/entities/perfil.dart';
import 'package:fix_flow/domain/entities/rol.dart';
import 'package:fix_flow/domain/errors/falla_red.dart';
import 'package:fix_flow/domain/validators/campos_validators.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import '../mocks.dart';

void main() {
  group('HU-25: Perfil arma el nombre completo y las iniciales', () {
    const perfil = Perfil(id: 1, nombre: 'Mariana', apellidos: 'García Ruiz', correo: 'm@mail.com', rol: Rol.ciudadano);

    test('Nombre y apellidos → «Mariana García Ruiz» y «MG»', () {
      expect(perfil.nombreCompleto, 'Mariana García Ruiz');
      expect(perfil.iniciales, 'MG');
    });

    test('Sin apellidos → solo el nombre y una inicial', () {
      const sinApellidos = Perfil(id: 1, nombre: 'Ana', apellidos: '', correo: 'a@mail.com', rol: Rol.admin);
      expect(sinApellidos.nombreCompleto, 'Ana');
      expect(sinApellidos.iniciales, 'A');
    });
  });

  group('HU-25: La nueva contraseña cumple RN-02 y es distinta de la actual', () {
    test('Igual a la actual → «Debe ser distinta de la actual»', () {
      expect(validarPasswordNueva(() => 'abc12345')('abc12345'), 'Debe ser distinta de la actual');
    });

    test('Solo letras → error de la política', () {
      expect(validarPasswordNueva(() => 'abc12345')('abcdefgh'), 'Debe incluir números');
    });

    test('Válida y distinta → sin error', () {
      expect(validarPasswordNueva(() => 'abc12345')('nueva2026'), isNull);
    });

    test('Los requisitos se marcan conforme se cumplen', () {
      expect(requisitosPassword('', 'abc12345'), (largo: false, letrasYNumeros: false, distinta: false));
      expect(requisitosPassword('abc12345', 'abc12345'), (largo: true, letrasYNumeros: true, distinta: false));
      expect(requisitosPassword('nueva2026', 'abc12345'), (largo: true, letrasYNumeros: true, distinta: true));
    });
  });

  group('HU-25: AuthRemoteDataSource habla con /usuarios/me', () {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
    final servidor = DioAdapter(dio: dio);
    final datasource = AuthRemoteDataSource(dio);
    const usuario = {
      'id': 7,
      'nombre': 'Ana',
      'apellidos': 'López Ruiz',
      'correo': 'ana@mail.com',
      'rol': 'CIUDADANO',
      'activo': true,
    };

    test('GET 200 → perfil con nombre, apellidos, correo y rol', () async {
      servidor.onGet('/usuarios/me', (s) => s.reply(200, {'text': 'OK', 'type': 'SUCCESS', 'result': usuario}));

      final res = await datasource.miPerfil();

      final perfil = (res as Ok<PerfilModel>).value.toEntity();
      expect(perfil.nombre, 'Ana');
      expect(perfil.apellidos, 'López Ruiz');
      expect(perfil.correo, 'ana@mail.com');
      expect(perfil.rol, Rol.ciudadano);
    });

    test('PUT manda solo nombre y apellidos', () async {
      servidor.onPut(
        '/usuarios/me',
        (s) => s.reply(200, {
          'text': 'Datos actualizados',
          'type': 'SUCCESS',
          'result': {...usuario, 'nombre': 'Ana María'},
        }),
        data: {'nombre': 'Ana María', 'apellidos': 'López Ruiz'},
      );

      final res = await datasource.actualizarPerfil(nombre: 'Ana María', apellidos: 'López Ruiz');

      expect((res as Ok<PerfilModel>).value.nombre, 'Ana María');
    });

    test('PATCH 200 → devuelve el texto del back', () async {
      servidor.onPatch(
        '/usuarios/me/password',
        (s) => s.reply(200, {'text': 'Contraseña actualizada', 'type': 'SUCCESS', 'result': null}),
        data: {'actual': 'abc12345', 'nueva': 'nueva2026'},
      );

      final res = await datasource.cambiarPassword(actual: 'abc12345', nueva: 'nueva2026');

      expect((res as Ok<String?>).value, 'Contraseña actualizada');
    });

    test('PATCH 400 → falla con el mensaje del back', () async {
      servidor.onPatch(
        '/usuarios/me/password',
        (s) => s.reply(400, {'text': 'La contraseña actual no es correcta', 'type': 'ERROR', 'result': null}),
        data: {'actual': 'mala1234', 'nueva': 'nueva2026'},
      );

      final res = await datasource.cambiarPassword(actual: 'mala1234', nueva: 'nueva2026');

      final falla = (res as Error<String?>).error;
      expect(falla, isA<PeticionRechazada>());
      expect((falla as PeticionRechazada).mensaje, 'La contraseña actual no es correcta');
    });
  });

  group('HU-25: AuthRepositoryImpl con el back simulado', () {
    late SessionStorage session;
    late AuthRepositoryImpl repo;

    setUp(() async {
      session = SessionStorage(crearStorageEnMemoria());
      repo = AuthRepositoryImpl(remote: FakeAuthRemoteDataSource(), session: session);
      await repo.iniciarSesion('operativo@fixflow.mx', FakeAuthRemoteDataSource.passwordDemo);
    });

    test('miPerfil() devuelve los datos de quien inició sesión', () async {
      final perfil = (await repo.miPerfil() as Ok<Perfil>).value;
      expect(perfil.correo, 'operativo@fixflow.mx');
      expect(perfil.rol, Rol.operativo);
    });

    test('actualizarPerfil() guarda el nombre nuevo para el saludo', () async {
      await repo.actualizarPerfil(nombre: 'Luis Alberto', apellidos: 'Ramírez');
      expect(await session.leerNombre(), 'Luis Alberto');

      await repo.actualizarPerfil(nombre: 'Luis', apellidos: 'Ramírez');
    });

    test('cambiarPassword() con la actual incorrecta se rechaza con un mensaje', () async {
      final res = await repo.cambiarPassword(actual: 'mala1234', nueva: 'nueva2026');
      expect((res as Error<String?>).error, isA<PeticionRechazada>());
    });

    test('cambiarPassword() correcto: la contraseña nueva sirve para entrar', () async {
      await repo.cambiarPassword(actual: FakeAuthRemoteDataSource.passwordDemo, nueva: 'nueva2026');
      await repo.cerrarSesion();

      expect(await repo.iniciarSesion('operativo@fixflow.mx', 'nueva2026'), isA<Ok<Object>>());

      await repo.cambiarPassword(actual: 'nueva2026', nueva: FakeAuthRemoteDataSource.passwordDemo);
    });
  });
}
