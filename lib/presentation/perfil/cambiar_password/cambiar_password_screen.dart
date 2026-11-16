import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../domain/validators/campos_validators.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/campo_texto.dart';
import '../widgets/aviso_error.dart';
import 'cambiar_password_viewmodel.dart';

class CambiarPasswordScreen extends StatefulWidget {
  const CambiarPasswordScreen({super.key});

  @override
  State<CambiarPasswordScreen> createState() => _CambiarPasswordScreenState();
}

class _CambiarPasswordScreenState extends State<CambiarPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _actual = TextEditingController();
  final _nueva = TextEditingController();
  final _confirmar = TextEditingController();
  bool _actualVisible = false;
  bool _nuevaVisible = false;
  bool _confirmarVisible = false;

  @override
  void dispose() {
    _actual.dispose();
    _nueva.dispose();
    _confirmar.dispose();
    super.dispose();
  }

  Future<void> _cambiar() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final vm = context.read<CambiarPasswordViewModel>();
    await vm.cambiar(actual: _actual.text, nueva: _nueva.text);
    if (!mounted) return;

    final exito = vm.exito;
    if (exito != null) context.pop(exito);
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          key: const Key('cambiar_password_regresar'),
          tooltip: 'Regresar',
          color: AppColors.textSecondary,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Cambiar contraseña'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Escribe tu contraseña actual y la nueva.',
                  style: texto.bodyLarge?.copyWith(fontSize: 15, height: 22 / 15, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                CampoTexto(
                  etiqueta: 'Contraseña actual',
                  child: _CampoPassword(
                    llave: const Key('password_actual'),
                    controller: _actual,
                    visible: _actualVisible,
                    alternar: () => setState(() => _actualVisible = !_actualVisible),
                    autofill: AutofillHints.password,
                    validator: validarObligatorio,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(height: 16),
                CampoTexto(
                  etiqueta: 'Nueva contraseña',
                  child: _CampoPassword(
                    llave: const Key('password_nueva'),
                    controller: _nueva,
                    visible: _nuevaVisible,
                    alternar: () => setState(() => _nuevaVisible = !_nuevaVisible),
                    autofill: AutofillHints.newPassword,
                    validator: validarPasswordNueva(() => _actual.text),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(height: 12),
                _Requisitos(requisitos: requisitosPassword(_nueva.text, _actual.text)),
                const SizedBox(height: 16),
                CampoTexto(
                  etiqueta: 'Confirmar nueva contraseña',
                  child: _CampoPassword(
                    llave: const Key('password_confirmar'),
                    controller: _confirmar,
                    visible: _confirmarVisible,
                    alternar: () => setState(() => _confirmarVisible = !_confirmarVisible),
                    autofill: AutofillHints.newPassword,
                    validator: validarConfirmarPassword(() => _nueva.text),
                    accion: TextInputAction.done,
                    onSubmitted: (_) => _cambiar(),
                  ),
                ),
                const SizedBox(height: 24),
                Consumer<CambiarPasswordViewModel>(
                  builder: (context, vm, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (vm.error != null) ...[AvisoError(mensaje: vm.error!), const SizedBox(height: 16)],
                      FilledButton(
                        key: const Key('password_cambiar'),
                        onPressed: vm.guardando ? null : _cambiar,
                        child: vm.guardando
                            ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2.5))
                            : const Text('Cambiar contraseña'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        key: const Key('password_cancelar'),
                        onPressed: vm.guardando ? null : () => context.pop(),
                        child: const Text('Cancelar'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CampoPassword extends StatelessWidget {
  const _CampoPassword({
    required this.llave,
    required this.controller,
    required this.visible,
    required this.alternar,
    required this.autofill,
    required this.validator,
    this.accion = TextInputAction.next,
    this.onChanged,
    this.onSubmitted,
  });

  final Key llave;
  final TextEditingController controller;
  final bool visible;
  final VoidCallback alternar;
  final String autofill;
  final FormFieldValidator<String> validator;
  final TextInputAction accion;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: llave,
      controller: controller,
      obscureText: !visible,
      textInputAction: accion,
      autofillHints: [autofill],
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: '••••••••',
        suffixIcon: IconButton(
          tooltip: visible ? 'Ocultar contraseña' : 'Mostrar contraseña',
          color: AppColors.textSecondary,
          icon: Icon(visible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
          onPressed: alternar,
        ),
      ),
    );
  }
}

class _Requisitos extends StatelessWidget {
  const _Requisitos({required this.requisitos});

  final RequisitosPassword requisitos;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Requisito(texto: 'Al menos 8 caracteres', cumplido: requisitos.largo),
          const SizedBox(height: 4),
          _Requisito(texto: 'Letras y números', cumplido: requisitos.letrasYNumeros),
          const SizedBox(height: 4),
          _Requisito(texto: 'Distinta de la actual', cumplido: requisitos.distinta),
        ],
      ),
    );
  }
}

class _Requisito extends StatelessWidget {
  const _Requisito({required this.texto, required this.cumplido});

  final String texto;
  final bool cumplido;

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontSize: 13,
        fontWeight: cumplido ? FontWeight.w600 : FontWeight.w500,
        color: cumplido ? AppColors.resuelta : AppColors.textMuted,
      ),
    );
  }
}
