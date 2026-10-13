// Test tipo Unitarias: se prueba una clase o función sin pantalla y sin red real

import 'package:dio/dio.dart';
import 'package:fix_flow/core/result.dart';
import 'package:fix_flow/data/datasources/local/session_storage.dart';
import 'package:fix_flow/data/datasources/remote/auth_remote_datasource.dart';
import 'package:fix_flow/data/models/login_response_model.dart';
import 'package:fix_flow/domain/entities/rol.dart';
import 'package:fix_flow/domain/errors/auth_failure.dart';
import 'package:fix_flow/presentation/routing/home_por_rol.dart';
import 'package:fix_flow/presentation/routing/rutas.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import '../mocks.dart';

void main() {
  group('HU-02: AuthService.login() interpreta la respuesta (simulada)', () {
    // Un Dio con un servidor simulado: no sale a la red
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
    final servidor = DioAdapter(dio: dio);
    final datasource = AuthRemoteDataSource(dio);
    const credenciales = {'correo': 'ana@mail.com', 'password': 'abc12345'};

    test('200 → devuelve token y rol', () async {
      servidor.onPost(
        '/auth/login',
        (s) => s.reply(200, {'token': 'jwt-123', 'rol': 'CIUDADANO', 'nombre': 'Ana'}),
        data: credenciales,
      );

      final res = await datasource.login('ana@mail.com', 'abc12345');

      expect(res, isA<Ok<LoginResponseModel>>());
      expect((res as Ok<LoginResponseModel>).value.token, 'jwt-123');
      expect(res.value.rol, 'CIUDADANO');
    });

    test('401 → error de tipo "credenciales no válidas"', () async {
      servidor.onPost(
        '/auth/login',
        (s) => s.reply(401, {'mensaje': 'Credenciales no válidas'}),
        data: credenciales,
      );

      final res = await datasource.login('ana@mail.com', 'abc12345');

      expect(res, isA<Error<LoginResponseModel>>());
      expect((res as Error<LoginResponseModel>).error, isA<CredencialesInvalidas>());
    });
  });

  group('HU-02: SessionStorage guarda y borra el token', () {
    test('Después de guardar, leer devuelve el token', () async {
      final session = SessionStorage(crearStorageEnMemoria());

      await session.guardarToken('jwt-123');

      expect(await session.leerToken(), 'jwt-123');
    });

    test('Después de borrar, leer devuelve null', () async {
      final session = SessionStorage(crearStorageEnMemoria());

      await session.guardarToken('jwt-123');
      await session.borrarToken();

      expect(await session.leerToken(), isNull);
    });
  });

  group('HU-02: La función que elige la home según el rol (CA-5)', () {
    test('CIUDADANO → home de ciudadano', () {
      expect(rutaHomePorRol(Rol.desde('CIUDADANO')), Rutas.homeCiudadano);
    });

    test('OPERATIVO → home de operativo', () {
      expect(rutaHomePorRol(Rol.desde('OPERATIVO')), Rutas.homeOperativo);
    });

    test('ADMIN → home de administrador', () {
      expect(rutaHomePorRol(Rol.desde('ADMIN')), Rutas.homeAdmin);
    });

    test('Rol desconocido → regresa al login', () {
      expect(rutaHomePorRol(Rol.desde('SUPERVISOR')), Rutas.login);
    });
  });
}
