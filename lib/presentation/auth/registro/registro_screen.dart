import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../domain/validators/campos_validators.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
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
      // Íconos de la barra de estado en oscuro sobre el fondo blanco
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    key: const Key('registro_regresar'),
                    tooltip: 'Regresar',
                    color: AppColors.textSecondary,
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.go(Rutas.login),
                  ),
                ),
                const _Marca(),
                const SizedBox(height: 32),
                Text(
                  'Crea tu cuenta',
                  style: text.headlineSmall?.copyWith(fontSize: 24, height: 30 / 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'Regístrate para reportar incidencias y darles seguimiento.',
                  style: text.bodyLarge?.copyWith(fontSize: 15, height: 22 / 15, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
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
                            etiqueta: 'Nombre',
                            child: TextFormField(
                              key: const Key('registro_nombre'),
                              controller: _nombre,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.givenName],
                              validator: validarObligatorio,
                              decoration: const InputDecoration(hintText: 'Ana'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          CampoTexto(
                            etiqueta: 'Apellidos',
                            child: TextFormField(
                              key: const Key('registro_apellidos'),
                              controller: _apellidos,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.familyName],
                              validator: validarObligatorio,
                              decoration: const InputDecoration(hintText: 'López Ruiz'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          CampoTexto(
                            etiqueta: 'Correo electrónico',
                            child: TextFormField(
                              key: const Key('registro_correo'),
                              controller: _correo,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email],
                              validator: validarCorreo,
                              decoration: const InputDecoration(hintText: 'ejemplo@gmail.com'),
                            ),
                          ),
                          const SizedBox(height: 16),
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
                                hintText: '••••••••',
                                helperText: 'Mínimo 8 caracteres, con letras y números',
                                suffixIcon: IconButton(
                                  key: const Key('registro_ver_password'),
                                  tooltip: _passwordVisible ? 'Ocultar contraseña' : 'Mostrar contraseña',
                                  color: AppColors.textSecondary,
                                  icon: Icon(_passwordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                                  onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
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
                                hintText: '••••••••',
                                suffixIcon: IconButton(
                                  key: const Key('registro_ver_confirmar'),
                                  tooltip: _confirmarVisible ? 'Ocultar contraseña' : 'Mostrar contraseña',
                                  color: AppColors.textSecondary,
                                  icon: Icon(_confirmarVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                                  onPressed: () => setState(() => _confirmarVisible = !_confirmarVisible),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
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
                                          dimension: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2.5),
                                        )
                                      : const Text('Crear cuenta'),
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

/// Logo de la llave con el nombre de la app, centrado arriba del título.
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
