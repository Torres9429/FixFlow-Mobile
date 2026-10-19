import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../domain/validators/campos_validators.dart';
import '../../core/theme/app_colors.dart';
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
      // Íconos de la barra de estado en blanco sobre el encabezado azul
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _Encabezado(),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 32, 28, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                      Text(
                        'Inicia sesión',
                        style: text.headlineSmall?.copyWith(fontSize: 24, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 18),
                      CampoTexto(
                        etiqueta: 'Correo electrónico',
                        child: TextFormField(
                          key: const Key('login_correo'),
                          controller: _correo,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          validator: validarObligatorio,
                          decoration: const InputDecoration(hintText: 'ana@mail.com'),
                        ),
                      ),
                      const SizedBox(height: 18),
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
                            helperText: 'Mínimo 8 caracteres, con letras y números.',
                            suffixIcon: IconButton(
                              key: const Key('login_ver_password'),
                              tooltip: _passwordVisible ? 'Ocultar contraseña' : 'Mostrar contraseña',
                              color: AppColors.textMuted,
                              icon: Icon(_passwordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                              onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
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
                                      dimension: 22,
                                      child: CircularProgressIndicator(strokeWidth: 2.5),
                                    )
                                  : const Text('Iniciar sesión'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
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
                    ],
                  ),
                ),
              ),
            ],
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

class _Encabezado extends StatelessWidget {
  const _Encabezado();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      height: 300,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(color: AppColors.primary),
      child: Stack(
        children: [
          // Decoración: círculo naranja y cuadro girado
          Positioned(
            right: -80,
            top: -70,
            child: Container(
              width: 230,
              height: 230,
              decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
            ),
          ),
          Positioned(
            right: 120,
            top: 56,
            child: Transform.rotate(
              angle: 18 * 3.1415926535 / 180,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.accent, width: 4),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.location_on_outlined, size: 30, color: AppColors.primary),
                ),
                const SizedBox(height: 12),
                Text(
                  'FixFlow',
                  style: text.displaySmall?.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.7,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Reporta. Sigue. Resuelve.',
                  style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w500, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
