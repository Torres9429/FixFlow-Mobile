import 'package:flutter/foundation.dart';

import '../config/app_config.dart';

/// Único lugar donde la app escribe logs. No usar `print` ni `debugPrint` fuera de aquí.
///
/// - dev: debug, info y error con el detalle.
/// - qa: info y error.
/// - prod o cualquier build `--release`: solo el tipo del error (`SocketException`), nunca el mensaje,
///   porque ahí pueden viajar correos, tokens o rutas del back.
abstract final class Bitacora {
  /// Dónde se escribe. Las pruebas lo cambian para capturar las líneas.
  @visibleForTesting
  static void Function(String linea) escribir = debugPrint;

  @visibleForTesting
  static NivelLog nivel = AppConfig.nivelLog;

  @visibleForTesting
  static bool enRelease = kReleaseMode;

  static void debug(String etiqueta, String mensaje) {
    if (_activo(NivelLog.debug)) escribir('[DEBUG][$etiqueta] $mensaje');
  }

  static void info(String etiqueta, String mensaje) {
    if (_activo(NivelLog.info)) escribir('[INFO][$etiqueta] $mensaje');
  }

  static void error(String etiqueta, Object error, [StackTrace? stack]) {
    if (enRelease || nivel == NivelLog.error) {
      escribir('[ERROR][$etiqueta] ${error.runtimeType}');
      return;
    }
    escribir('[ERROR][$etiqueta] $error');
    if (stack != null) escribir('$stack');
  }

  // En release se callan debug e info aunque el config sea dev
  static bool _activo(NivelLog nivelDelMensaje) => !enRelease && nivelDelMensaje.index >= nivel.index;
}
