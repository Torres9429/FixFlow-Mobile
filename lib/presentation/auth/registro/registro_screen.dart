import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../domain/validators/campos_validators.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/campo_texto.dart';

import '../../routing/rutas.dart';
import 'registro_viewmodel.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _apellidos = TextEditingController();
  final _correo = TextEditingController();
  final _password = TextEditingController();
  final _confirmar = TextEditingController();
  bool _passwordVisible = false;
  bool _confirmarVisible = false;

  @override
  void dispose() {
    _nombre.dispose();
    _apellidos.dispose();
    _correo.dispose();
    _password.dispose();
    _confirmar.dispose();
    super.dispose();
  }

  Future<void> _crearCuenta() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final vm = context.read<RegistroViewModel>();
    await vm.registrar(
      nombre: _nombre.text,
      apellidos: _apellidos.text,
      correo: _correo.text,
      password: _password.text,
    );
    if (!mounted) return;

    if (vm.registroExitoso) {
      context.go(Uri(path: Rutas.login, queryParameters: {'cuentaCreada': 'true'}).toString());
    }
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
                      // ── Nombre y Apellidos en fila ──
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: CampoTexto(
                              etiqueta: 'Nombre',
                              child: TextFormField(
                                key: const Key('registro_nombre'),
                                controller: _nombre,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.givenName],
                                validator: validarObligatorio,
                                decoration: const InputDecoration(hintText: 'Ana'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: CampoTexto(
                              etiqueta: 'Apellidos',
                              child: TextFormField(
                                key: const Key('registro_apellidos'),
                                controller: _apellidos,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.familyName],
                                validator: validarObligatorio,
                                decoration: const InputDecoration(hintText: 'López Ruiz'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // ── Correo ──
                      CampoTexto(
                        etiqueta: 'Correo electrónico',
                        child: TextFormField(
                          key: const Key('registro_correo'),
                          controller: _correo,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          validator: validarCorreo,
                          decoration: const InputDecoration(hintText: 'ana@mail.com'),
                        ),
                      ),
                      const SizedBox(height: 18),
                      // ── Contraseña ──
                      CampoTexto(
                        etiqueta: 'Contraseña',
                        child: TextFormField(
                          key: const Key('registro_password'),
                          controller: _password,
                          obscureText: !_passwordVisible,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.newPassword],
                          validator: validarPassword,
                          decoration: InputDecoration(
                            helperText: 'Mínimo 8 caracteres, con letras y números.',
                            suffixIcon: IconButton(
                              key: const Key('registro_ver_password'),
                              tooltip: _passwordVisible ? 'Ocultar contraseña' : 'Mostrar contraseña',
                              color: AppColors.textMuted,
                              icon: Icon(_passwordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                              onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      // ── Confirmar contraseña ──
                      CampoTexto(
                        etiqueta: 'Confirmar contraseña',
                        child: TextFormField(
                          key: const Key('registro_confirmar'),
                          controller: _confirmar,
                          obscureText: !_confirmarVisible,
                          textInputAction: TextInputAction.done,
                          validator: validarConfirmarPassword(() => _password.text),
                          onFieldSubmitted: (_) => _crearCuenta(),
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              key: const Key('registro_ver_confirmar'),
                              tooltip: _confirmarVisible ? 'Ocultar contraseña' : 'Mostrar contraseña',
                              color: AppColors.textMuted,
                              icon: Icon(_confirmarVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                              onPressed: () => setState(() => _confirmarVisible = !_confirmarVisible),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Consumer<RegistroViewModel>(
                        builder: (context, vm, _) => Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (vm.error != null) ...[
                              _AvisoError(mensaje: vm.error!),
                              const SizedBox(height: 16),
                            ],
                            FilledButton(
                              key: const Key('registro_crear'),
                              onPressed: vm.cargando ? null : _crearCuenta,
                              child: vm.cargando
                                  ? const SizedBox.square(
                                      dimension: 22,
                                      child: CircularProgressIndicator(strokeWidth: 2.5),
                                    )
                                  : const Text('Crear cuenta'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '¿Ya tienes cuenta?',
                            style: text.bodyLarge?.copyWith(fontSize: 15, color: AppColors.textSecondary),
                          ),
                          TextButton(
                            onPressed: () => context.go(Rutas.login),
                            child: const Text('Inicia sesión'),
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
      height: 200,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(color: AppColors.primary),
      child: Stack(
        children: [
          // Decoración: círculo naranja
          Positioned(
            right: -80,
            top: -70,
            child: Container(
              width: 230,
              height: 230,
              decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
            ),
          ),
          // Cuadro girado decorativo
          Positioned(
            right: 120,
            top: 40,
            child: Transform.rotate(
              angle: 18 * 3.1415926535 / 180,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.accent, width: 3),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Botón de regreso
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    key: const Key('registro_regresar'),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.go(Rutas.login),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Crea tu cuenta',
                  style: text.headlineSmall?.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Para reportar y dar seguimiento',
                  style: text.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
