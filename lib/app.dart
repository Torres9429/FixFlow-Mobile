import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/incidence_type_repository.dart';
import 'data/repositories/fake_incidence_type_repository.dart';
import 'presentation/core/theme/app_theme.dart';
import 'presentation/routing/router.dart';

/// Recibe sus dependencias en lugar de crearlas, para que las pruebas
/// puedan levantar la app con mocks.
class FixFlowApp extends StatefulWidget {
  const FixFlowApp({super.key, required this.authRepository, this.incidenceTypeRepository});

  final AuthRepository authRepository;
  final IncidenceTypeRepository? incidenceTypeRepository;

  @override
  State<FixFlowApp> createState() => _FixFlowAppState();
}

class _FixFlowAppState extends State<FixFlowApp> {
  late final GoRouter _router = crearRouter();

  @override
  void dispose() {
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
      ],
      child: MaterialApp.router(
        title: 'FixFlow',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: _router,
      ),
    );
  }
}
