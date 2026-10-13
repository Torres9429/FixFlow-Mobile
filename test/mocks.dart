// Mocks compartidos por las pruebas de interfaz e integración

import 'package:fix_flow/domain/repositories/auth_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

/// MockSecureStorage que guarda en un Map, como si fuera el almacenamiento real.
/// Sigue siendo un mock: se puede usar verify sobre sus llamadas.
MockSecureStorage crearStorageEnMemoria() {
  final datos = <String, String>{};
  final storage = MockSecureStorage();

  when(() => storage.write(key: any(named: 'key'), value: any(named: 'value'))).thenAnswer((inv) async {
    final clave = inv.namedArguments[#key] as String;
    final valor = inv.namedArguments[#value] as String?;
    if (valor == null) {
      datos.remove(clave);
    } else {
      datos[clave] = valor;
    }
  });
  when(() => storage.read(key: any(named: 'key')))
      .thenAnswer((inv) async => datos[inv.namedArguments[#key] as String]);
  when(() => storage.delete(key: any(named: 'key')))
      .thenAnswer((inv) async => datos.remove(inv.namedArguments[#key] as String));

  return storage;
}
