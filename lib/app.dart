import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/sesion/sesion_expirada.dart';
import 'data/repositories/fake_incidence_type_repository.dart';
import 'data/repositories/fakes/fake_admin_repository.dart';
import 'data/repositories/fakes/fake_evidencia_repository.dart';
import 'data/repositories/fakes/fake_inclinacion_repository.dart';
import 'data/repositories/fakes/fake_operativo_repository.dart';
import 'data/repositories/fakes/fake_reportes_ciudadano_repository.dart';
import 'data/repositories/fakes/fake_ubicacion_repository.dart';
import 'domain/repositories/admin_repository.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/evidencia_repository.dart';
import 'domain/repositories/incidence_type_repository.dart';
import 'domain/repositories/inclinacion_repository.dart';
import 'domain/repositories/operativo_repository.dart';
import 'domain/repositories/reportes_ciudadano_repository.dart';
import 'domain/repositories/ubicacion_repository.dart';
import 'presentation/core/theme/app_theme.dart';
import 'presentation/routing/router.dart';
import 'presentation/routing/rutas.dart';

/// Recibe sus dependencias en lugar de crearlas, para que las pruebas
/// puedan levantar la app con mocks. Las que no se pasan usan su fake.
class FixFlowApp extends StatefulWidget {
  const FixFlowApp({
    super.key,
    required this.authRepository,
    this.incidenceTypeRepository,
    this.reportesCiudadanoRepository,
    this.operativoRepository,
    this.adminRepository,
    this.ubicacionRepository,
    this.evidenciaRepository,
    this.inclinacionRepository,
    this.sesionExpirada,
  });

  final AuthRepository authRepository;
  final IncidenceTypeRepository? incidenceTypeRepository;
  final ReportesCiudadanoRepository? reportesCiudadanoRepository;
  final OperativoRepository? operativoRepository;
  final AdminRepository? adminRepository;
  final UbicacionRepository? ubicacionRepository;
  final EvidenciaRepository? evidenciaRepository;
  final InclinacionRepository? inclinacionRepository;

  /// Avisa cuando la sesión ya no se pudo renovar; sin él (en las pruebas) no se escucha nada.
  final SesionExpirada? sesionExpirada;

  @override
  State<FixFlowApp> createState() => _FixFlowAppState();
}

class _FixFlowAppState extends State<FixFlowApp> {
  late final GoRouter _router = crearRouter();
  final _mensajero = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    widget.sesionExpirada?.addListener(_alExpirarSesion);
  }

  /// La sesión venció y no se pudo renovar: de regreso al login (RNF-09).
  void _alExpirarSesion() {
    _router.go(Rutas.login);
    _mensajero.currentState
      ?..clearSnackBars()
      ..showSnackBar(const SnackBar(content: Text('Tu sesión terminó. Inicia sesión de nuevo.')));
  }

  @override
  void dispose() {
    widget.sesionExpirada?.removeListener(_alExpirarSesion);
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: widget.authRepository),
        Provider<IncidenceTypeRepository>(
          create: (_) => widget.incidenceTypeRepository ?? FakeIncidenceTypeRepository(),
        ),
        Provider<ReportesCiudadanoRepository>(
          create: (_) => widget.reportesCiudadanoRepository ?? FakeReportesCiudadanoRepository(),
        ),
        Provider<OperativoRepository>(create: (_) => widget.operativoRepository ?? FakeOperativoRepository()),
        Provider<AdminRepository>(create: (_) => widget.adminRepository ?? FakeAdminRepository()),
        Provider<UbicacionRepository>(create: (_) => widget.ubicacionRepository ?? FakeUbicacionRepository()),
        Provider<EvidenciaRepository>(create: (_) => widget.evidenciaRepository ?? FakeEvidenciaRepository()),
        Provider<InclinacionRepository>(create: (_) => widget.inclinacionRepository ?? FakeInclinacionRepository()),
      ],
      child: MaterialApp.router(
        scaffoldMessengerKey: _mensajero,
        title: 'FixFlow',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: _router,
      ),
    );
  }
}
