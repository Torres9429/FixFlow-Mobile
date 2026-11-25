// Test tipo Unitarias: se prueba una clase o función sin pantalla y sin red real

import 'package:fix_flow/core/config/app_config.dart';
import 'package:fix_flow/core/log/bitacora.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late List<String> lineas;

  setUp(() {
    lineas = [];
    Bitacora.escribir = lineas.add;
  });

  void configurar({required NivelLog nivel, bool release = false}) {
    Bitacora.nivel = nivel;
    Bitacora.enRelease = release;
  }

  group('Modos de compilación: logs según el ambiente', () {
    test('Cada ambiente tiene su nivel: dev todo, qa desde info, prod solo errores', () {
      expect(AppConfig.nivelPara('dev'), NivelLog.debug);
      expect(AppConfig.nivelPara('qa'), NivelLog.info);
      expect(AppConfig.nivelPara('PROD'), NivelLog.error);
    });

    test('En dev se escribe todo, y el error con su detalle', () {
      configurar(nivel: NivelLog.debug);

      Bitacora.debug('http', '→ GET /tipos-incidencia');
      Bitacora.info('arranque', 'ambiente=dev');
      Bitacora.error('No se pudo leer el GPS', const FormatException('sin señal'));

      expect(lineas, [
        '[DEBUG][http] → GET /tipos-incidencia',
        '[INFO][arranque] ambiente=dev',
        '[ERROR][No se pudo leer el GPS] FormatException: sin señal',
      ]);
    });

    test('En prod se callan debug e info, y del error solo sale el tipo', () {
      configurar(nivel: NivelLog.error);

      Bitacora.debug('http', '→ POST /auth/login');
      Bitacora.info('push', 'Token de FCM registrado');
      Bitacora.error('No se pudo guardar el token', const FormatException('correo@utez.edu.mx'));

      expect(lineas, ['[ERROR][No se pudo guardar el token] FormatException']);
    });

    test('Un build release no filtra detalles aunque el config sea dev', () {
      configurar(nivel: NivelLog.debug, release: true);

      Bitacora.debug('http', '→ POST /auth/login');
      Bitacora.error('No se pudo renovar la sesión', Exception('refresh=abc123'));

      expect(lineas, ['[ERROR][No se pudo renovar la sesión] _Exception']);
      expect(lineas.join(), isNot(contains('abc123')));
    });
  });
}
