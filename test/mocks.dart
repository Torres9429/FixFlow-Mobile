// Mocks compartidos por las pruebas de interfaz e integración

import 'package:fix_flow/domain/repositories/admin_repository.dart';
import 'package:fix_flow/domain/repositories/auth_repository.dart';
import 'package:fix_flow/domain/repositories/avisos_repository.dart';
import 'package:fix_flow/domain/repositories/evidencia_repository.dart';
import 'package:fix_flow/domain/repositories/incidence_type_repository.dart';
import 'package:fix_flow/domain/repositories/incidencias_repository.dart';
import 'package:fix_flow/domain/repositories/inclinacion_repository.dart';
import 'package:fix_flow/domain/repositories/operativo_repository.dart';
import 'package:fix_flow/domain/repositories/push_repository.dart';
import 'package:fix_flow/domain/repositories/reportes_ciudadano_repository.dart';
import 'package:fix_flow/domain/repositories/ubicacion_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockReportesCiudadanoRepository extends Mock implements ReportesCiudadanoRepository {}

class MockAdminRepository extends Mock implements AdminRepository {}

class MockOperativoRepository extends Mock implements OperativoRepository {}

class MockIncidenciasRepository extends Mock implements IncidenciasRepository {}

class MockEvidenciaRepository extends Mock implements EvidenciaRepository {}

class MockIncidenceTypeRepository extends Mock implements IncidenceTypeRepository {}

class MockUbicacionRepository extends Mock implements UbicacionRepository {}

class MockInclinacionRepository extends Mock implements InclinacionRepository {}

class MockPushRepository extends Mock implements PushRepository {}

class MockAvisosRepository extends Mock implements AvisosRepository {}

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

/// MockSecureStorage que guarda en un Map, como si fuera el almacenamiento real.
/// Sigue siendo un mock: se puede usar verify sobre sus llamadas.
MockSecureStorage crearStorageEnMemoria() {
  final datos = <String, String>{};
  final storage = MockSecureStorage();

  when(
    () => storage.write(
      key: any(named: 'key'),
      value: any(named: 'value'),
    ),
  ).thenAnswer((inv) async {
    final clave = inv.namedArguments[#key] as String;
    final valor = inv.namedArguments[#value] as String?;
    if (valor == null) {
      datos.remove(clave);
    } else {
      datos[clave] = valor;
    }
  });
  when(() => storage.read(key: any(named: 'key'))).thenAnswer((inv) async => datos[inv.namedArguments[#key] as String]);
  when(() => storage.delete(key: any(named: 'key')))
      .thenAnswer((inv) async => datos.remove(inv.namedArguments[#key] as String));

  return storage;
}
