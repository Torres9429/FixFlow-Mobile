import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../domain/repositories/auth_repository.dart';
import '../routing/rutas.dart';

/// Estructura común de las homes mientras se diseñan las pantallas de cada rol.
class HomeBase extends StatelessWidget {
  const HomeBase({super.key, required this.titulo, required this.descripcion, this.acciones = const []});

  final String titulo;
  final String descripcion;
  final List<Widget> acciones;

  Future<void> _cerrarSesion(BuildContext context) async {
    await context.read<AuthRepository>().cerrarSesion();
    if (!context.mounted) return;
    context.go(Rutas.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(descripcion, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 24),
              ...acciones,
              if (acciones.isNotEmpty) const SizedBox(height: 16),
              OutlinedButton.icon(
                key: const Key('cerrar_sesion'),
                onPressed: () => _cerrarSesion(context),
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
