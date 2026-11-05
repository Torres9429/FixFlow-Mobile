import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../domain/validators/campos_validators.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/campo_texto.dart';
import '../../routing/home_por_rol.dart';
import '../../routing/rutas.dart';
import 'login_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.cuentaCreada = false});

  final bool cuentaCreada;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correo = TextEditingController();
  final _password = TextEditingController();
  bool _passwordVisible = false;

  @override
  void dispose() {
    _correo.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final vm = context.read<LoginViewModel>();
    await vm.iniciarSesion(_correo.text, _password.text);
    if (!mounted) return;

    final usuario = vm.usuario;
    if (usuario != null) context.go(rutaHomePorRol(usuario.rol));
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Íconos de la barra de estado en oscuro sobre el fondo blanco
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _Marca(),
                const SizedBox(height: 32),
                Text(
                  'Hola de nuevo',
                  style: text.headlineSmall?.copyWith(fontSize: 24, height: 30 / 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ingresa tus credenciales para acceder al sistema.',
                  style: text.bodyLarge?.copyWith(fontSize: 15, height: 22 / 15, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                if (widget.cuentaCreada) ...[
                  Container(
                    key: const Key('login_cuenta_creada'),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.resueltaBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, size: 20, color: AppColors.resuelta),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Cuenta creada',
                            style: text.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.resuelta,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Tarjeta del formulario
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radius),
                    boxShadow: AppTheme.sombra,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CampoTexto(
                            etiqueta: 'Correo electrónico',
                            child: TextFormField(
                              key: const Key('login_correo'),
                              controller: _correo,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email],
                              validator: validarObligatorio,
                              decoration: const InputDecoration(
                                hintText: 'ejemplo@gmail.com',
                                helperText: 'Personal operativo o correo personal',
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          CampoTexto(
                            etiqueta: 'Contraseña',
                            child: TextFormField(
                              key: const Key('login_password'),
                              controller: _password,
                              obscureText: !_passwordVisible,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
                              validator: validarObligatorio,
                              onFieldSubmitted: (_) => _entrar(),
                              decoration: InputDecoration(
                                hintText: '••••••••',
                                suffixIcon: IconButton(
                                  key: const Key('login_ver_password'),
                                  tooltip: _passwordVisible ? 'Ocultar contraseña' : 'Mostrar contraseña',
                                  color: AppColors.textSecondary,
                                  icon: Icon(_passwordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                                  onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Consumer<LoginViewModel>(
                            builder: (context, vm, _) => Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (vm.error != null) ...[
                                  _AvisoError(mensaje: vm.error!),
                                  const SizedBox(height: 16),
                                ],
                                FilledButton(
                                  key: const Key('login_entrar'),
                                  onPressed: vm.cargando ? null : _entrar,
                                  child: vm.cargando
                                      ? const SizedBox.square(
                                          dimension: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2.5),
                                        )
                                      : const Text('Iniciar sesión'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿No tienes cuenta?',
                      style: text.bodyLarge?.copyWith(fontSize: 15, color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () => context.go(Rutas.registro),
                      child: const Text('Crea una'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  'Versión 1.0.0',
                  textAlign: TextAlign.center,
                  style: text.bodySmall?.copyWith(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AvisoError extends StatelessWidget {
  const _AvisoError({required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.prioridadAltaBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 20, color: AppColors.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mensaje,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Logo de la llave con el nombre de la app, centrado arriba del saludo.
class _Marca extends StatelessWidget {
  const _Marca();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
            boxShadow: AppTheme.sombra,
          ),
          child: const Icon(Icons.build_outlined, size: 18, color: Colors.white),
        ),
        const SizedBox(height: 12),
        Text(
          'FixFlow',
          style: text.titleMedium?.copyWith(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.2),
        ),
        const SizedBox(height: 4),
        Text(
          'Gestión de incidencias',
          style: text.bodySmall?.copyWith(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
