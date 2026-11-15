import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/result.dart';
import '../../domain/errors/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../core/mensajes.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/campo_texto.dart';
import '../routing/rutas.dart';
import '../../domain/validators/campos_validators.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _actual = TextEditingController();
  final _nueva = TextEditingController();
  final _confirmar = TextEditingController();
  bool _guardando = false;
  String? _error;

  @override
  void dispose() {
    _actual.dispose();
    _nueva.dispose();
    _confirmar.dispose();
    super.dispose();
  }

  Future<void> _cambiarPassword() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _guardando = true;
      _error = null;
    });

    final resultado = await context.read<AuthRepository>().cambiarPassword(
      actual: _actual.text,
      nueva: _nueva.text,
    );
    if (!mounted) return;
    setState(() => _guardando = false);
    switch (resultado) {
      case Ok<void>():
        _formKey.currentState!.reset();
        _actual.clear();
        _nueva.clear();
        _confirmar.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contraseña actualizada correctamente.'),
          ),
        );
      case Error<void>(error: final error):
        setState(
          () => _error = switch (error) {
            CredencialesInvalidas() => 'La contraseña actual no es correcta.',
            _ => mensajePara(error),
          },
        );
    }
  }

  Future<void> _cerrarSesion() async {
    await context.read<AuthRepository>().cerrarSesion();
    if (!mounted) return;
    context.go(Rutas.login);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Perfil')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Cambiar contraseña',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Reemplaza tu contraseña temporal por una propia.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CampoTexto(
                  etiqueta: 'Contraseña actual',
                  child: TextFormField(
                    key: const Key('password_actual'),
                    controller: _actual,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    validator: validarObligatorio,
                    decoration: const InputDecoration(hintText: '••••••••'),
                  ),
                ),
                const SizedBox(height: 16),
                CampoTexto(
                  etiqueta: 'Nueva contraseña',
                  child: TextFormField(
                    key: const Key('password_nueva'),
                    controller: _nueva,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    validator: validarPassword,
                    decoration: const InputDecoration(
                      hintText: 'Mínimo 8 caracteres',
                      helperText: 'Debe incluir letras y números.',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CampoTexto(
                  etiqueta: 'Confirmar nueva contraseña',
                  child: TextFormField(
                    key: const Key('password_confirmar'),
                    controller: _confirmar,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    validator: (valor) {
                      final error = validarObligatorio(valor);
                      if (error != null) return error;
                      return valor == _nueva.text
                          ? null
                          : 'Las contraseñas no coinciden.';
                    },
                    decoration: const InputDecoration(hintText: '••••••••'),
                    onFieldSubmitted: (_) => _cambiarPassword(),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    key: const Key('error_cambiar_password'),
                    style: const TextStyle(color: AppColors.error),
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  key: const Key('guardar_password'),
                  onPressed: _guardando ? null : _cambiarPassword,
                  child: _guardando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Actualizar contraseña'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            key: const Key('cerrar_sesion'),
            onPressed: _cerrarSesion,
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    ),
  );
}
