import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../domain/validators/campos_validators.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/campo_texto.dart';
import '../nombre_rol.dart';
import '../widgets/aviso_error.dart';
import '../widgets/campo_bloqueado.dart';
import 'editar_datos_viewmodel.dart';

class EditarDatosScreen extends StatefulWidget {
  const EditarDatosScreen({super.key});

  @override
  State<EditarDatosScreen> createState() => _EditarDatosScreenState();
}

class _EditarDatosScreenState extends State<EditarDatosScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _apellidos;

  @override
  void initState() {
    super.initState();
    final perfil = context.read<EditarDatosViewModel>().perfil;
    _nombre = TextEditingController(text: perfil.nombre);
    _apellidos = TextEditingController(text: perfil.apellidos);
  }

  @override
  void dispose() {
    _nombre.dispose();
    _apellidos.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final vm = context.read<EditarDatosViewModel>();
    await vm.guardar(nombre: _nombre.text, apellidos: _apellidos.text);
    if (!mounted) return;

    final guardado = vm.guardado;
    if (guardado != null) context.pop(guardado);
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final perfil = context.read<EditarDatosViewModel>().perfil;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          key: const Key('editar_datos_regresar'),
          tooltip: 'Regresar',
          color: AppColors.textSecondary,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Editar mis datos'),
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
                  'Corrige tu nombre y tus apellidos.',
                  style: texto.bodyLarge?.copyWith(fontSize: 15, height: 22 / 15, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                CampoTexto(
                  etiqueta: 'Nombre',
                  child: TextFormField(
                    key: const Key('editar_nombre'),
                    controller: _nombre,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.givenName],
                    validator: validarObligatorio,
                  ),
                ),
                const SizedBox(height: 16),
                CampoTexto(
                  etiqueta: 'Apellidos',
                  child: TextFormField(
                    key: const Key('editar_apellidos'),
                    controller: _apellidos,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.familyName],
                    validator: validarObligatorio,
                    onFieldSubmitted: (_) => _guardar(),
                  ),
                ),
                const SizedBox(height: 16),
                CampoTexto(
                  etiqueta: 'Correo electrónico',
                  child: CampoBloqueado(key: const Key('editar_correo'), valor: perfil.correo),
                ),
                const SizedBox(height: 16),
                CampoTexto(
                  etiqueta: 'Rol',
                  child: CampoBloqueado(key: const Key('editar_rol'), valor: nombreRol(perfil.rol)),
                ),
                const SizedBox(height: 12),
                Text(
                  'El correo y el rol no se pueden cambiar desde la app.',
                  style: texto.bodySmall?.copyWith(fontSize: 13, color: AppColors.textMuted),
                ),
                const SizedBox(height: 24),
                Consumer<EditarDatosViewModel>(
                  builder: (context, vm, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (vm.error != null) ...[AvisoError(mensaje: vm.error!), const SizedBox(height: 16)],
                      FilledButton(
                        key: const Key('editar_guardar'),
                        onPressed: vm.guardando ? null : _guardar,
                        child: vm.guardando
                            ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2.5))
                            : const Text('Guardar cambios'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        key: const Key('editar_cancelar'),
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
