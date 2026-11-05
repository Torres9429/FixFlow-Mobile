import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../domain/repositories/auth_repository.dart';
import '../core/theme/app_colors.dart';
import '../routing/rutas.dart';

/// A3 Perfil. Por ahora solo cierra sesión; los datos, A3a, A3b y A3c llegan con la tarjeta de HU-25.
class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  Future<void> _cerrarSesion(BuildContext context) async {
    await context.read<AuthRepository>().cerrarSesion();
    if (!context.mounted) return;
    context.go(Rutas.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              FilledButton(
                key: const Key('cerrar_sesion'),
                style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                onPressed: () => _cerrarSesion(context),
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
