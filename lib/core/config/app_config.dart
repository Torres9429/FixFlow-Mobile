/// Ambiente actual, leído de `--dart-define-from-file=config/<ambiente>.json`.
abstract final class AppConfig {
  static const env = String.fromEnvironment('ENV', defaultValue: 'dev');
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const logHttp = bool.fromEnvironment('LOG_HTTP');

  /// Back simulado: con `config/mock.json`, o si se corre sin `--dart-define-from-file`.
  static const usarMocks = bool.fromEnvironment('USE_MOCKS') || apiBaseUrl == '';

  static bool get esProd => env == 'prod';
}
