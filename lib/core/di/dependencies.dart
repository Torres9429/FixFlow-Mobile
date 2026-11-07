import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../data/datasources/device/direccion_datasource.dart';
import '../../data/datasources/device/inclinacion_datasource.dart';
import '../../data/datasources/device/ubicacion_datasource.dart';
import '../../data/datasources/local/session_storage.dart';
import '../../data/datasources/remote/api_client.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/remote/fake_auth_remote_datasource.dart';
import '../../data/repositories/admin_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/evidencia_repository_impl.dart';
import '../../data/repositories/fakes/fake_admin_repository.dart';
import '../../data/repositories/fakes/fake_direccion_repository.dart';
import '../../data/repositories/fakes/fake_evidencia_repository.dart';
import '../../data/repositories/fakes/fake_incidencias_repository.dart';
import '../../data/repositories/fakes/fake_inclinacion_repository.dart';
import '../../data/repositories/fakes/fake_operativo_repository.dart';
import '../../data/repositories/fakes/fake_reportes_ciudadano_repository.dart';
import '../../data/repositories/fakes/fake_ubicacion_repository.dart';
import '../../data/repositories/incidencias_repository_impl.dart';
import '../../data/repositories/operativo_repository_impl.dart';
import '../../data/repositories/reportes_ciudadano_repository_impl.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/direccion_repository.dart';
import '../../domain/repositories/evidencia_repository.dart';
import '../../domain/repositories/incidencias_repository.dart';
import '../../domain/repositories/incidence_type_repository.dart';
import '../../domain/repositories/inclinacion_repository.dart';
import '../../domain/repositories/operativo_repository.dart';
import '../../domain/repositories/reportes_ciudadano_repository.dart';
import '../../domain/repositories/ubicacion_repository.dart';
import '../../data/repositories/fake_incidence_type_repository.dart';
import '../../data/repositories/incidence_type_repository_impl.dart';
import '../config/app_config.dart';
import '../sesion/sesion_expirada.dart';

/// Lo que la app recibe ya armado. Solo este archivo conoce las clases de `data/`.
class Dependencias {
  const Dependencias({
    required this.authRepository,
    required this.incidenceTypeRepository,
    required this.reportesCiudadanoRepository,
    required this.operativoRepository,
    required this.adminRepository,
    required this.ubicacionRepository,
    required this.evidenciaRepository,
    required this.inclinacionRepository,
    required this.incidenciasRepository,
    required this.direccionRepository,
    required this.sesionExpirada,
  });

  final AuthRepository authRepository;
  final IncidenceTypeRepository incidenceTypeRepository;
  final ReportesCiudadanoRepository reportesCiudadanoRepository;
  final OperativoRepository operativoRepository;
  final AdminRepository adminRepository;
  final UbicacionRepository ubicacionRepository;
  final EvidenciaRepository evidenciaRepository;
  final InclinacionRepository inclinacionRepository;
  final IncidenciasRepository incidenciasRepository;
  final DireccionRepository direccionRepository;
  final SesionExpirada sesionExpirada;
}

Dependencias crearDependencias() {
  final session = SessionStorage(const FlutterSecureStorage());
  final sesionExpirada = SesionExpirada();
  final api = ApiClient(session: session, alExpirarSesion: sesionExpirada.avisar);
  const mock = AppConfig.usarMocks;

  // En modo mock solo cambia la fuente remota; repositorio y token son los reales
  final authRemote = mock ? FakeAuthRemoteDataSource() : AuthRemoteDataSource(api.dio);

  return Dependencias(
    authRepository: AuthRepositoryImpl(remote: authRemote, session: session),
    incidenceTypeRepository: mock ? FakeIncidenceTypeRepository() : IncidenceTypeRepositoryImpl(api.dio),
    reportesCiudadanoRepository: mock ? FakeReportesCiudadanoRepository() : ReportesCiudadanoRepositoryImpl(api.dio),
    operativoRepository: mock ? FakeOperativoRepository() : OperativoRepositoryImpl(api.dio),
    adminRepository: mock ? FakeAdminRepository() : AdminRepositoryImpl(api.dio),
    ubicacionRepository: mock ? FakeUbicacionRepository() : UbicacionDataSource(),
    evidenciaRepository: mock ? FakeEvidenciaRepository() : EvidenciaRepositoryImpl(api.dio),
    inclinacionRepository: mock ? FakeInclinacionRepository() : InclinacionDataSource(),
    incidenciasRepository: mock ? FakeIncidenciasRepository() : IncidenciasRepositoryImpl(api.dio),
    direccionRepository: mock ? FakeDireccionRepository() : DireccionDataSource(),
    sesionExpirada: sesionExpirada,
  );
}
