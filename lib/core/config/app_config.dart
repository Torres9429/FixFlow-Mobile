/// Nivel mínimo que se escribe en la bitácora (ver `core/log/bitacora.dart`).
enum NivelLog { debug, info, error }

/// Ambiente actual, leído de `--dart-define-from-file=config/<ambiente>.json`.
///
/// - `mock.json`: dev con back simulado (también el botón ▶ sin argumentos).
/// - `dev.json` / `device.json`: dev contra el back en la laptop.
/// - `prod.json`: el APK release de la entrega (`flutter build apk --release ...`).
abstract final class AppConfig {
  static const env = String.fromEnvironment('ENV', defaultValue: 'dev');

  /// Vacío = no se pasó config: se usa el back simulado.
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const version = String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0');
  static const logHttp = bool.fromEnvironment('LOG_HTTP');

  /// Back simulado: con `config/mock.json`, o si se corre sin `--dart-define-from-file`.
  static const usarMocks = bool.fromEnvironment('USE_MOCKS') || apiBaseUrl == '';

  /// Push (FCM) con el proyecto real de Firebase (antes: `flutterfire configure`).
  static const usarFirebase = bool.fromEnvironment('FIREBASE');

  static bool get esProd => env == 'prod';

  /// dev escribe todo, qa desde info y prod solo errores.
  static NivelLog get nivelLog => nivelPara(env);

  static NivelLog nivelPara(String ambiente) => switch (ambiente.toLowerCase()) {
    'prod' => NivelLog.error,
    'qa' => NivelLog.info,
    _ => NivelLog.debug,
  };
}
