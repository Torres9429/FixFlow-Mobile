import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../domain/validators/campos_validators.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/campo_texto.dart';
import '../../core/widgets/hoja_confirmacion.dart';
import 'alta_operativo_viewmodel.dart';

class AltaOperativoScreen extends StatefulWidget {
  const AltaOperativoScreen({super.key});

  @override
  State<AltaOperativoScreen> createState() => _AltaOperativoScreenState();
}

class _AltaOperativoScreenState extends State<AltaOperativoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _apellidos = TextEditingController();
  final _correo = TextEditingController();
  final _password = TextEditingController(text: _generarPassword());
  bool _passwordVisible = false;

  @override
  void dispose() {
    _nombre.dispose();
    _apellidos.dispose();
    _correo.dispose();
    _password.dispose();
    super.dispose();
  }

  static String _generarPassword() {
    const letras = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
    const digitos = '23456789';
    const permitidos = '$letras$digitos!@#';
    final random = Random.secure();
    final caracteres = <String>[
      letras[random.nextInt(letras.length)],
      digitos[random.nextInt(digitos.length)],
      for (var i = 0; i < 10; i++)
        permitidos[random.nextInt(permitidos.length)],
    ]..shuffle(random);
    return caracteres.join();
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final creado = await context.read<AltaOperativoViewModel>().crear(
      nombre: _nombre.text,
      apellidos: _apellidos.text,
      correo: _correo.text.toLowerCase(),
      passwordTemporal: _password.text,
    );
    if (!mounted || !creado) return;
    final correo = _correo.text.trim();
    final password = _password.text;
    // Hoja inferior como el resto de los diálogos; no se cierra al tocar fuera para no perder las credenciales
    await mostrarHoja<void>(
      context,
      descartable: false,
      builder: (hojaContext) => ContenidoHoja(
        titulo: 'Operativo registrado',
        mensaje:
            'Comparte estas credenciales con ${_nombre.text.trim()}. Podrá cambiar la contraseña desde su perfil después de iniciar sesión.',
        detalle: DatosHoja(
          datos: [('Correo', correo), ('Contraseña temporal', password)],
        ),
        acciones: [
          FilledButton(
            key: const Key('alta_listo'),
            onPressed: () => Navigator.pop(hojaContext),
            child: const Text('Listo'),
          ),
          const SizedBox(height: 8),
          TextButton(
            key: const Key('alta_copiar_password'),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: password));
              if (hojaContext.mounted) Navigator.pop(hojaContext);
            },
            child: const Text('Copiar contraseña'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    context.pop(true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        tooltip: 'Regresar',
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      title: const Text('Nuevo operativo'),
    ),
    body: SafeArea(
      child: Consumer<AltaOperativoViewModel>(
        builder: (context, vm, _) => Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              const Text(
                'Registrar nuevo operador',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                'Crea sus credenciales para que pueda ingresar al sistema.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              CampoTexto(
                etiqueta: 'Nombre',
                child: TextFormField(
                  key: const Key('operativo_nombre'),
                  controller: _nombre,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: validarObligatorio,
                  decoration: const InputDecoration(hintText: 'Roberto'),
                ),
              ),
              const SizedBox(height: 16),
              CampoTexto(
                etiqueta: 'Apellidos',
                child: TextFormField(
                  key: const Key('operativo_apellidos'),
                  controller: _apellidos,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: validarObligatorio,
                  decoration: const InputDecoration(hintText: 'Mendoza López'),
                ),
              ),
              const SizedBox(height: 16),
              CampoTexto(
                etiqueta: 'Correo electrónico institucional',
                child: TextFormField(
                  key: const Key('operativo_correo'),
                  controller: _correo,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: validarCorreo,
                  decoration: const InputDecoration(
                    hintText: 'ej. r.mendoza@municipio.gob.mx',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Contraseña temporal asignada',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton(
                        key: const Key('generar_password_operativo'),
                        onPressed: () =>
                            setState(() => _password.text = _generarPassword()),
                        child: const Text('Autogenerar'),
                      ),
                    ],
                  ),
                  TextFormField(
                    key: const Key('operativo_password_temporal'),
                    controller: _password,
                    obscureText: !_passwordVisible,
                    validator: validarPassword,
                    decoration: InputDecoration(
                      helperText:
                          'El operativo podrá cambiarla desde su perfil.',
                      suffixIcon: IconButton(
                        key: const Key('ver_password_operativo'),
                        tooltip: _passwordVisible
                            ? 'Ocultar contraseña'
                            : 'Mostrar contraseña',
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () => setState(
                          () => _passwordVisible = !_passwordVisible,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: AppColors.primary),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Comparte la contraseña temporal de forma segura. Por seguridad, se guardará protegida y no podrá consultarse después.',
                      ),
                    ),
                  ],
                ),
              ),
              if (vm.error != null) ...[
                const SizedBox(height: 16),
                Text(
                  vm.error!,
                  key: const Key('error_alta_operativo'),
                  style: const TextStyle(color: AppColors.error),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                key: const Key('crear_operativo'),
                onPressed: vm.guardando ? null : _registrar,
                child: vm.guardando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Registrar operativo'),
              ),
              TextButton(
                onPressed: vm.guardando ? null : () => context.pop(),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
