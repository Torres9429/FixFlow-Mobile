import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Guarda el JWT en el almacenamiento seguro del dispositivo.
class SessionStorage {
  SessionStorage(this._storage);

  static const _claveToken = 'token';

  final FlutterSecureStorage _storage;

  Future<void> guardarToken(String token) => _storage.write(key: _claveToken, value: token);

  Future<String?> leerToken() => _storage.read(key: _claveToken);

  Future<void> borrarToken() => _storage.delete(key: _claveToken);
}
