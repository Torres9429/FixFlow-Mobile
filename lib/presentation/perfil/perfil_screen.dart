import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/config/app_config.dart';
import '../../domain/entities/perfil.dart';
import '../core/estado_consulta.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/estado_vacio.dart';
import '../routing/rutas.dart';
import 'nombre_rol.dart';
import 'perfil_viewmodel.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key, this.comoPestana = false});

  final bool comoPestana;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: comoPestana
            ? null
            : IconButton(
                key: const Key('perfil_regresar'),
                tooltip: 'Regresar',
                color: AppColors.textSecondary,
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
        title: const Text('Perfil'),
      ),
      body: SafeArea(
        child: Consumer<PerfilViewModel>(
          builder: (context, vm, _) => switch (vm.estado) {
            Cargando() => const Center(child: CircularProgressIndicator()),
            ConError(:final mensaje) => SingleChildScrollView(
              child: EstadoVacio.error(mensaje: mensaje, onReintentar: vm.cargar),
            ),
            Listo(datos: final perfil) => _ContenidoPerfil(perfil: perfil),
          },
        ),
      ),
    );
  }
}

class _ContenidoPerfil extends StatelessWidget {
  const _ContenidoPerfil({required this.perfil});

  final Perfil perfil;

  Future<void> _cerrarSesion(BuildContext context) async {
    await context.read<PerfilViewModel>().cerrarSesion();
    if (!context.mounted) return;
    context.go(Rutas.login);
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        _Encabezado(perfil: perfil),
        const SizedBox(height: 28),
        Text(
          'CUENTA Y SEGURIDAD',
          style: texto.labelMedium?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radius),
            boxShadow: AppTheme.sombra,
          ),
          child: const Column(
            children: [
              _FilaPerfil(
                llave: Key('perfil_editar_datos'),
                titulo: 'Editar mis datos',
                subtitulo: 'Nombre y apellidos',
              ),
              Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.borderSubtle),
              _FilaPerfil(
                llave: Key('perfil_cambiar_password'),
                titulo: 'Cambiar contraseña',
                subtitulo: 'Seguridad de la cuenta',
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        FilledButton(
          key: const Key('cerrar_sesion'),
          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
          onPressed: () => _cerrarSesion(context),
          child: const Text('Cerrar sesión'),
        ),
        const SizedBox(height: 16),
        Text(
          'FixFlow · versión ${AppConfig.version}',
          textAlign: TextAlign.center,
          style: texto.bodySmall?.copyWith(fontSize: 13, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.perfil});

  final Perfil perfil;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;

    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          child: Text(
            perfil.iniciales,
            style: texto.titleLarge?.copyWith(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.surface),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          perfil.nombreCompleto,
          key: const Key('perfil_nombre'),
          textAlign: TextAlign.center,
          style: texto.titleLarge?.copyWith(fontSize: 20, height: 26 / 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          perfil.correo,
          key: const Key('perfil_correo'),
          textAlign: TextAlign.center,
          style: texto.bodyMedium?.copyWith(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 10),
        Container(
          height: 24,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(999)),
          child: Text(
            nombreRol(perfil.rol),
            key: const Key('perfil_rol'),
            style: texto.labelMedium?.copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _FilaPerfil extends StatelessWidget {
  const _FilaPerfil({required this.llave, required this.titulo, required this.subtitulo});

  final Key llave;
  final String titulo;
  final String subtitulo;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;

    return ListTile(
      key: llave,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(titulo, style: texto.bodyLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitulo, style: texto.bodySmall?.copyWith(fontSize: 13, color: AppColors.textMuted)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: null,
    );
  }
}
