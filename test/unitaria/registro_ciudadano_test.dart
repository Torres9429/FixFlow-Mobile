// Test tipo Unitarias: se prueba una clase o función sin pantalla y sin red real

import 'package:dio/dio.dart';
import 'package:fix_flow/core/result.dart';
import 'package:fix_flow/data/datasources/remote/auth_remote_datasource.dart';
import 'package:fix_flow/data/models/registro_response_model.dart';
import 'package:fix_flow/domain/errors/auth_failure.dart';
import 'package:fix_flow/domain/validators/campos_validators.dart';
import 'package:fix_flow/presentation/auth/registro/registro_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks.dart';

void main() {
  group('HU-01: El validador de contraseña (CA-4)', () {
    test('abc12345 → sin error', () {
      expect(validarPassword('abc12345'), isNull);
    });

    test('abcdefgh (solo letras) → mensaje de error', () {
      expect(validarPassword('abcdefgh'), isNotNull);
    });

    test('12345678 (solo números) → mensaje de error', () {
      expect(validarPassword('12345678'), isNotNull);
    });

    test('abc123 (menos de 8 caracteres) → mensaje de error', () {
      expect(validarPassword('abc123'), isNotNull);
    });
  });

  group('HU-01: Los validadores de campos obligatorios y del correo (CA-2)', () {
    test('Vacío → "Campo obligatorio"', () {
      expect(validarCorreo(''), 'Campo obligatorio');
      expect(validarObligatorio(''), 'Campo obligatorio');
    });

    test('ana@ → "Correo no válido"', () {
      expect(validarCorreo('ana@'), 'Correo no válido');
    });

    test('ana@mail.com → sin error', () {
      expect(validarCorreo('ana@mail.com'), isNull);
    });
  });

  group('HU-01: AuthRemoteDataSource.registro() habla con /usuarios/registro', () {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
    final servidor = DioAdapter(dio: dio);
    final datasource = AuthRemoteDataSource(dio);
    const datosRegistro = {
      'nombre': 'Ana',
      'apellidos': 'López',
      'correo': 'ana@mail.com',
      'password': 'abc12345',
    };

    test('200 → registro exitoso en /usuarios/registro', () async {
      servidor.onPost(
        '/usuarios/registro',
        (s) => s.reply(200, {
          'text': 'Usuario creado exitosamente',
          'type': 'SUCCESS',
          'result': {
            'id': 1,
            'nombre': 'Ana',
            'apellidos': 'López',
            'correo': 'ana@mail.com',
            'rol': 'CIUDADANO',
          },
        }),
        data: datosRegistro,
      );

      final res = await datasource.registro(
        nombre: 'Ana',
        apellidos: 'López',
        correo: 'ana@mail.com',
        password: 'abc12345',
      );

      expect(res, isA<Ok<RegistroResponseModel>>());
      expect((res as Ok<RegistroResponseModel>).value.nombre, 'Ana');
      expect(res.value.rol, 'CIUDADANO');
    });

    test('409 → correo duplicado', () async {
      servidor.onPost(
        '/usuarios/registro',
        (s) => s.reply(409, {'mensaje': 'Ya existe una cuenta con ese correo'}),
        data: datosRegistro,
      );

      final res = await datasource.registro(
        nombre: 'Ana',
        apellidos: 'López',
        correo: 'ana@mail.com',
        password: 'abc12345',
      );

      expect(res, isA<Error<RegistroResponseModel>>());
      expect((res as Error<RegistroResponseModel>).error, isA<CorreoDuplicado>());
    });
  });

  group('HU-01: RegistroViewModel gestiona respuestas de registro', () {
    test('CorreoDuplicado → muestra el aviso de correo ya registrado', () async {
      final repo = MockAuthRepository();
      when(() => repo.registrar(
            nombre: any(named: 'nombre'),
            apellidos: any(named: 'apellidos'),
            correo: any(named: 'correo'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => const Result.error(CorreoDuplicado()));

      final vm = RegistroViewModel(authRepository: repo);

      await vm.registrar(
        nombre: 'Ana',
        apellidos: 'López',
        correo: 'ana@mail.com',
        password: 'abc12345',
      );

      expect(vm.error, 'Ya existe una cuenta con ese correo');
      expect(vm.registroExitoso, false);
    });
  });
}
