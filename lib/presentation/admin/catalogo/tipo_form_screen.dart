import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/prioridad.dart';
import '../../../domain/entities/tipo_incidencia.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/campo_bloqueado.dart';
import 'confirmar_estatus_tipo.dart';
import 'textos_tipo.dart';
import 'tipo_form_viewmodel.dart';

/// E11 Nuevo tipo y E12 Editar tipo. Al guardar regresa a E10 con `true`.
class TipoFormScreen extends StatelessWidget {
  const TipoFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TipoFormViewModel>(
      builder: (context, vm, _) {
        final texto = Theme.of(context).textTheme;
        final ayuda = texto.bodySmall?.copyWith(fontSize: 13, color: AppColors.textMuted);
        final tipo = vm.tipo;

        return Scaffold(
          appBar: AppBar(title: const Text('Catálogo de tipos')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              _Encabezado(vm: vm),
              const SizedBox(height: 20),
              if (tipo == null) ...[const _TarjetaValidacion(), const SizedBox(height: 24)],
              if (tipo != null && !tipo.activo) ...[const _AvisoInactivo(), const SizedBox(height: 20)],

              const _Etiqueta('Nombre del tipo'),
              TextFormField(
                key: const Key('campo_nombre_tipo'),
                initialValue: vm.nombre,
                enabled: !vm.guardando,
                maxLength: 80,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'ej. Hundimiento de banqueta',
                  helperText: 'Es el nombre que ve el ciudadano al reportar.',
                  errorText: vm.errorNombre,
                  counterText: '',
                ),
                onChanged: vm.cambiarNombre,
              ),
              const SizedBox(height: 16),

              _Etiqueta(
                'Código del tipo',
                insignia: !vm.esEdicion && vm.codigo.trim().isEmpty ? 'Autogenerado' : null,
              ),
              if (vm.esEdicion) ...[
                // Mismo campo bloqueado que el correo y el rol en A3a (design.md: sin candado)
                CampoBloqueado(key: const Key('campo_codigo_tipo'), valor: vm.codigo),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('El código no se puede cambiar.', style: ayuda),
                ),
              ] else
                TextFormField(
                  key: const Key('campo_codigo_tipo'),
                  initialValue: vm.codigo,
                  enabled: !vm.guardando,
                  maxLength: 30,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(letterSpacing: 0.5),
                  decoration: InputDecoration(
                    hintText: codigoSugerido(vm.nombre).isEmpty ? 'HUNDIMIENTO_BANQUETA' : codigoSugerido(vm.nombre),
                    helperText: vm.ayudaCodigo,
                    helperMaxLines: 2,
                    errorText: vm.errorCodigo,
                    errorMaxLines: 2,
                    counterText: '',
                  ),
                  onChanged: vm.cambiarCodigo,
                ),
              const SizedBox(height: 20),

              const _Etiqueta('Prioridad base'),
              _SelectorPrioridad(
                seleccionada: vm.prioridad,
                onSeleccionar: vm.guardando ? null : vm.elegirPrioridad,
              ),
              if (vm.errorPrioridad case final error?) _Error(error),
              const SizedBox(height: 20),

              const _Etiqueta('Orientación de la cámara'),
              _SelectorOrientacion(
                seleccionada: vm.orientacion,
                onSeleccionar: vm.guardando ? null : vm.elegirOrientacion,
              ),
              if (vm.errorOrientacion case final error?) _Error(error),
              const SizedBox(height: 8),
              Text('La cámara solo deja tomar la foto con el teléfono en esta inclinación.', style: ayuda),

              if (vm.esEdicion) ...[
                const SizedBox(height: 20),
                Text('Los cambios aplican a los reportes nuevos; los existentes conservan su prioridad.', style: ayuda),
              ] else ...[
                const SizedBox(height: 24),
                _ActivoAlCrear(vm: vm),
              ],

              // Al final del formulario, como en nuevo operativo (E9)
              const SizedBox(height: 24),
              FilledButton(
                key: const Key('guardar_tipo'),
                onPressed: vm.guardando ? null : () => _guardar(context, vm),
                child: vm.guardando
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(vm.esEdicion ? 'Guardar cambios' : 'Guardar tipo'),
              ),
              if (tipo == null)
                TextButton(onPressed: vm.guardando ? null : () => context.pop(), child: const Text('Cancelar'))
              else
                TextButton(
                  key: const Key('estatus_tipo_form'),
                  style: tipo.activo ? TextButton.styleFrom(foregroundColor: AppColors.error) : null,
                  onPressed: vm.guardando ? null : () => _cambiarEstatus(context, vm, tipo),
                  child: Text(tipo.activo ? 'Desactivar' : 'Activar'),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _guardar(BuildContext context, TipoFormViewModel vm) async {
    final ok = await vm.guardar();
    if (!context.mounted) return;
    if (ok) {
      context.pop(true);
    } else {
      _avisarError(context, vm);
    }
  }

  /// E12a, o reactivar, con el mismo diálogo que E10.
  Future<void> _cambiarEstatus(BuildContext context, TipoFormViewModel vm, TipoIncidencia tipo) async {
    if (!await confirmarEstatusTipo(context, tipo) || !context.mounted) return;
    final ok = await vm.cambiarEstatus();
    if (!context.mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(avisoEstatusTipo(tipo))));
      context.pop(true);
    } else {
      _avisarError(context, vm);
    }
  }

  void _avisarError(BuildContext context, TipoFormViewModel vm) {
    if (vm.errorGeneral case final mensaje?) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
    }
  }
}

/// «CATÁLOGO DE TIPOS», el título grande y una línea de explicación.
class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.vm});

  final TipoFormViewModel vm;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final usos = vm.tipo?.incidencias ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.category_outlined, size: 16, color: AppColors.textMuted),
            const SizedBox(width: 6),
            Text(
              'CATÁLOGO DE TIPOS',
              style: texto.labelMedium?.copyWith(letterSpacing: 1, color: AppColors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          vm.esEdicion ? 'Editar tipo de incidencia' : 'Nuevo tipo de incidencia',
          style: texto.headlineSmall?.copyWith(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          vm.esEdicion
              ? '$usos ${usos == 1 ? 'incidencia usa' : 'incidencias usan'} este tipo.'
              : 'Agrega una categoría de reporte al catálogo municipal.',
          style: texto.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

/// Explica para qué sirven la orientación y la prioridad (solo en E11).
class _TarjetaValidacion extends StatelessWidget {
  const _TarjetaValidacion();

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppTheme.radius)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: AppColors.primaryContainer, shape: BoxShape.circle),
            child: const Icon(Icons.tune, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Validación de la foto',
                  style: texto.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'La orientación guía la cámara del ciudadano para que la evidencia le sirva al personal operativo.',
                  style: texto.bodySmall?.copyWith(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvisoInactivo extends StatelessWidget {
  const _AvisoInactivo();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: AppColors.campoBloqueado, borderRadius: BorderRadius.circular(10)),
    child: Row(
      children: [
        const Icon(Icons.info_outline, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Desactivado: no aparece en reportes nuevos',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 13, color: AppColors.textSecondary),
          ),
        ),
      ],
    ),
  );
}

/// Etiqueta encima del campo (design.md, Formularios), con una insignia opcional a la derecha.
class _Etiqueta extends StatelessWidget {
  const _Etiqueta(this.texto, {this.insignia});

  final String texto;
  final String? insignia;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(texto, style: tema.bodyMedium?.copyWith(fontSize: 15, fontWeight: FontWeight.w600))),
          if (insignia case final etiqueta?)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(999)),
              child: Text(
                etiqueta,
                style: tema.labelSmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error(this.mensaje);

  final String mensaje;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Text(
      mensaje,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 13, color: AppColors.error),
    ),
  );
}

/// Alta · Media · Baja en tres píldoras del mismo ancho.
class _SelectorPrioridad extends StatelessWidget {
  const _SelectorPrioridad({required this.seleccionada, required this.onSeleccionar});

  final Prioridad? seleccionada;
  final ValueChanged<Prioridad>? onSeleccionar;

  @override
  Widget build(BuildContext context) {
    final radio = BorderRadius.circular(999);
    return Row(
      children: [
        for (final (i, p) in Prioridad.values.indexed) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: Material(
              key: Key('prioridad_${p.name}'),
              color: p == seleccionada ? AppColors.primary : AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: radio,
                side: p == seleccionada ? BorderSide.none : const BorderSide(color: AppColors.borderSubtle),
              ),
              child: InkWell(
                borderRadius: radio,
                onTap: onSeleccionar == null ? null : () => onSeleccionar!(p),
                child: SizedBox(
                  height: 44,
                  child: Center(
                    child: Text(
                      textoPrioridad(p),
                      style: TextStyle(
                        fontWeight: p == seleccionada ? FontWeight.w700 : FontWeight.w500,
                        color: p == seleccionada ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Una fila por orientación, con su flecha y una palomita en la elegida.
class _SelectorOrientacion extends StatelessWidget {
  const _SelectorOrientacion({required this.seleccionada, required this.onSeleccionar});

  final OrientacionFoto? seleccionada;
  final ValueChanged<OrientacionFoto>? onSeleccionar;

  static String _detalle(OrientacionFoto o) => switch (o) {
    OrientacionFoto.sinRestriccion => 'Sin restricción (ángulo libre)',
    _ => textoOrientacion(o),
  };

  static IconData _icono(OrientacionFoto o) => switch (o) {
    OrientacionFoto.suelo => Icons.arrow_downward,
    OrientacionFoto.arriba => Icons.arrow_upward,
    OrientacionFoto.sinRestriccion => Icons.swap_horiz,
  };

  @override
  Widget build(BuildContext context) {
    final radio = BorderRadius.circular(12);
    return Column(
      children: [
        for (final o in OrientacionFoto.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              key: Key('orientacion_${o.name}'),
              color: o == seleccionada ? AppColors.primary : AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: radio,
                side: o == seleccionada ? BorderSide.none : const BorderSide(color: AppColors.borderSubtle),
              ),
              child: InkWell(
                borderRadius: radio,
                onTap: onSeleccionar == null ? null : () => onSeleccionar!(o),
                child: SizedBox(
                  height: 48,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(_icono(o), size: 18, color: o == seleccionada ? Colors.white : AppColors.textSecondary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _detalle(o),
                            style: TextStyle(
                              fontWeight: o == seleccionada ? FontWeight.w700 : FontWeight.w500,
                              color: o == seleccionada ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ),
                        if (o == seleccionada) const Icon(Icons.check, size: 20, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// «Activo inmediatamente» (solo en E11).
class _ActivoAlCrear extends StatelessWidget {
  const _ActivoAlCrear({required this.vm});

  final TipoFormViewModel vm;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppTheme.radius)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Activo inmediatamente',
                  style: texto.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  'Aparece al crear un reporte en cuanto lo guardes.',
                  style: texto.bodySmall?.copyWith(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            key: const Key('activo_al_crear'),
            value: vm.activoAlCrear,
            activeTrackColor: AppColors.primary,
            onChanged: vm.guardando ? null : vm.cambiarActivoAlCrear,
          ),
        ],
      ),
    );
  }
}
