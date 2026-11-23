import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/formato_fecha.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/campo_texto.dart';
import '../../incidencia/secciones/barra_acciones.dart';
import '../../core/widgets/aviso_error.dart';
import 'camara_solucion_screen.dart';
import 'solucion_viewmodel.dart';

/// D3 Registrar solución (HU-16 / design.md §10): foto en vivo sin guía de ángulo y descripción obligatoria.
class SolucionScreen extends StatefulWidget {
  const SolucionScreen({super.key, this.onTomarFoto});

  /// Permite sustituir la cámara en pruebas de interfaz.
  final Future<String?> Function(BuildContext)? onTomarFoto;

  @override
  State<SolucionScreen> createState() => _SolucionScreenState();
}

class _SolucionScreenState extends State<SolucionScreen> {
  final _descripcion = TextEditingController();

  @override
  void dispose() {
    _descripcion.dispose();
    super.dispose();
  }

  Future<void> _tomarFoto(BuildContext context, SolucionViewModel vm) async {
    final capturador = widget.onTomarFoto ??
        // Navegador raíz: la cámara ocupa toda la pantalla, sin la barra de navegación del operativo
        (ctx) => Navigator.of(ctx, rootNavigator: true).push<String>(
          MaterialPageRoute(builder: (_) => const CamaraSolucionScreen()),
        );
    final ruta = await capturador(context);
    if (!context.mounted || ruta == null) return;
    vm.establecerFoto(ruta);
  }

  Future<void> _enviar(BuildContext context, SolucionViewModel vm) async {
    FocusScope.of(context).unfocus();
    final ok = await vm.enviar();
    if (!context.mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solución registrada')),
      );
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final meta = texto.bodySmall?.copyWith(
      fontSize: 13,
      height: 18 / 13,
      fontWeight: FontWeight.w500,
      color: AppColors.textMuted,
    );

    return Consumer<SolucionViewModel>(
      builder: (context, vm, _) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Regresar',
            icon: const Icon(Icons.arrow_back),
            onPressed: vm.enviando ? null : () => context.pop(),
          ),
          title: const Text('Registrar solución'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CampoTexto(
                etiqueta: 'Foto de la solución',
                child: vm.rutaFoto == null
                    ? _CajaSinFoto(
                        conError: vm.errorFoto != null,
                        onTomarFoto: vm.enviando ? null : () => _tomarFoto(context, vm),
                      )
                    : _VistaPreviaFoto(
                        rutaFoto: vm.rutaFoto!,
                        capturadaEn: vm.capturadaEn,
                        onVolverACapturar: vm.enviando ? null : () => _tomarFoto(context, vm),
                        meta: meta,
                      ),
              ),
              if (vm.errorFoto case final error?) ...[
                const SizedBox(height: 6),
                Text(
                  error,
                  style: meta?.copyWith(color: AppColors.error),
                ),
              ],
              const SizedBox(height: 24),
              CampoTexto(
                etiqueta: 'Descripción de la solución',
                child: TextFormField(
                  key: const Key('solucion_descripcion'),
                  controller: _descripcion,
                  enabled: !vm.enviando,
                  minLines: 4,
                  maxLines: 6,
                  maxLength: SolucionViewModel.maxDescripcion,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: vm.cambiarDescripcion,
                  decoration: InputDecoration(
                    hintText: 'Describe qué trabajo realizaste para resolver la incidencia',
                    counterText: '',
                    errorText: vm.errorDescripcion,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Text('Obligatoria', style: meta)),
                  Text(
                    '${vm.descripcion.length}/${SolucionViewModel.maxDescripcion}',
                    key: const Key('solucion_contador'),
                    style: meta?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (vm.nombreOperativo.isNotEmpty) ...[
                Text('Se registrará a nombre de ${vm.nombreOperativo}', style: meta),
                const SizedBox(height: 4),
              ],
              Text('La incidencia pasará a Resuelta', style: meta),
              if (vm.errorGeneral case final error?) ...[
                const SizedBox(height: 16),
                AvisoError(key: const Key('solucion_error'), mensaje: error),
              ],
              // La acción va al final del formulario, no fija abajo
              const SizedBox(height: 24),
              BarraAcciones(
                primario: FilledButton(
                  key: const Key('solucion_enviar'),
                  onPressed: vm.enviando ? null : () => _enviar(context, vm),
                  child: vm.enviando
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Enviar solución'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CajaSinFoto extends StatelessWidget {
  const _CajaSinFoto({required this.conError, required this.onTomarFoto});

  final bool conError;
  final VoidCallback? onTomarFoto;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(
          color: conError ? AppColors.error : AppColors.border,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.photo_camera_outlined, size: 36, color: AppColors.textMuted),
          const SizedBox(height: 10),
          Text(
            'Toma una foto del trabajo terminado',
            textAlign: TextAlign.center,
            style: texto.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            key: const Key('solucion_tomar_foto'),
            onPressed: onTomarFoto,
            child: const Text('Tomar foto'),
          ),
        ],
      ),
    );
  }
}

class _VistaPreviaFoto extends StatelessWidget {
  const _VistaPreviaFoto({
    required this.rutaFoto,
    required this.capturadaEn,
    required this.onVolverACapturar,
    required this.meta,
  });

  final String rutaFoto;
  final DateTime? capturadaEn;
  final VoidCallback? onVolverACapturar;
  final TextStyle? meta;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Image.file(
              File(rutaFoto),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const ColoredBox(color: AppColors.surfaceMuted),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                capturadaEn == null ? 'Capturada' : formatearFechaCorta(capturadaEn!),
                style: meta,
              ),
            ),
            TextButton(
              key: const Key('solucion_volver_a_capturar'),
              onPressed: onVolverACapturar,
              child: const Text('Volver a capturar'),
            ),
          ],
        ),
      ],
    );
  }
}
