import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/incidencia_detalle.dart';
import '../../../domain/entities/operativo.dart';
import '../../../domain/entities/prioridad.dart';
import '../../core/estado_consulta.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/estado_vacio.dart';
import '../../core/widgets/estado_chip.dart';
import '../../core/widgets/prioridad_simbolo.dart';
import 'asignacion_viewmodel.dart';

class AsignacionScreen extends StatelessWidget {
  const AsignacionScreen({super.key});

  @override
  Widget build(BuildContext context) => Consumer<AsignacionViewModel>(
    builder: (context, vm, _) => Scaffold(
      appBar: AppBar(
        title: Text(
          vm.esReasignacion ? 'Reasignar incidencia' : 'Asignar incidencia',
        ),
      ),
      body: switch (vm.estado) {
        Cargando() => const Center(child: CircularProgressIndicator()),
        ConError(:final mensaje) => EstadoVacio.error(
          mensaje: mensaje,
          onReintentar: vm.iniciar,
        ),
        Listo(:final datos) => _Contenido(
          vm: vm,
          detalle: datos.detalle,
          operativos: datos.operativos,
        ),
      },
    ),
  );
}

class _Contenido extends StatelessWidget {
  const _Contenido({
    required this.vm,
    required this.detalle,
    required this.operativos,
  });

  final AsignacionViewModel vm;
  final IncidenciaDetalle detalle;
  final List<Operativo> operativos;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final responsable = detalle.responsableActual;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        _IncidenciaResumen(detalle: detalle, direccion: vm.direccion),
        if (vm.esReasignacion && responsable != null) ...[
          const SizedBox(height: 16),
          _ResponsableActual(nombre: responsable),
        ],
        const SizedBox(height: 24),
        Text(
          'Seleccionar personal operativo',
          style: texto.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Elige quien tenga menor carga de incidencias activas.',
          style: texto.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        ...operativos.map(
          (operativo) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _OperativoCard(
              operativo: operativo,
              seleccionado: vm.operativoSeleccionado == operativo.id,
              onTap: () => vm.seleccionar(operativo.id),
            ),
          ),
        ),
        if (operativos.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Text('No hay operativos activos disponibles para asignar.'),
          ),
        if (vm.errorFormulario case final error?) ...[
          const SizedBox(height: 4),
          Text(error, style: const TextStyle(color: AppColors.error)),
        ],
        const SizedBox(height: 16),
        _AvisoAsignacion(esReasignacion: vm.esReasignacion),
        const SizedBox(height: 16),
        SizedBox(
          height: 52,
          child: FilledButton(
            key: const Key('confirmar_asignacion'),
            onPressed: vm.guardando
                ? null
                : () async {
                    if (await vm.confirmar() && context.mounted) {
                      context.pop(true);
                    }
                  },
            child: vm.guardando
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    vm.esReasignacion
                        ? 'Confirmar reasignación'
                        : 'Confirmar asignación',
                  ),
          ),
        ),
        TextButton(
          onPressed: vm.guardando ? null : context.pop,
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}

class _ResponsableActual extends StatelessWidget {
  const _ResponsableActual({required this.nombre});

  final String nombre;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(AppTheme.radius),
    ),
    child: Row(
      children: [
        const Icon(Icons.person_outline, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Responsable actual',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                nombre,
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _AvisoAsignacion extends StatelessWidget {
  const _AvisoAsignacion({required this.esReasignacion});

  final bool esReasignacion;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(AppTheme.radius),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.info_outline,
          size: 24,
          color: AppColors.primary,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            esReasignacion
                ? 'Se notificará automáticamente al nuevo personal operativo (RN-18).'
                : 'Se notificará automáticamente al personal operativo y al ciudadano solicitante (RN-18).',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    ),
  );
}

class _IncidenciaResumen extends StatelessWidget {
  const _IncidenciaResumen({required this.detalle, this.direccion});

  final IncidenciaDetalle detalle;
  final String? direccion;

  @override
  Widget build(BuildContext context) {
    final resumen = detalle.resumen;
    final texto = Theme.of(context).textTheme;
    final motivo = resumen.motivoPrioridad;
    final (etiquetaPrioridad, colorPrioridad) = switch (resumen.prioridad) {
      Prioridad.alta => ('Prioridad alta', AppColors.prioridadAlta),
      Prioridad.media => ('Prioridad media', AppColors.prioridadMedia),
      Prioridad.baja => ('Prioridad baja', AppColors.prioridadBaja),
    };
    final ubicacion =
        direccion ??
        '${resumen.latitud.toStringAsFixed(5)}, ${resumen.longitud.toStringAsFixed(5)}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        boxShadow: AppTheme.sombra,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Folio ${resumen.folio}',
                      style: texto.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    EstadoChip(estado: resumen.estado),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ExcludeSemantics(
                          child: PrioridadSimbolo(prioridad: resumen.prioridad),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            etiquetaPrioridad,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: texto.bodyMedium?.copyWith(
                              color: colorPrioridad,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (motivo.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        motivo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: texto.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            resumen.tipo,
            style: texto.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: AppColors.placeholder,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ubicacion,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: texto.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OperativoCard extends StatelessWidget {
  const _OperativoCard({
    required this.operativo,
    required this.seleccionado,
    required this.onTap,
  });

  final Operativo operativo;
  final bool seleccionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: seleccionado,
    label:
        '${operativo.nombreCompleto}, ${operativo.cargaActual} incidencias activas',
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radius),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: seleccionado ? AppColors.primaryContainer : AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          border: Border.all(
            color: seleccionado ? AppColors.primary : AppColors.borderSubtle,
          ),
          boxShadow: AppTheme.sombra,
        ),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: AppColors.primaryContainer,
              child: Icon(Icons.person_outline, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    operativo.nombreCompleto,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${operativo.cargaActual} ${operativo.cargaActual == 1 ? 'incidencia activa' : 'incidencias activas'}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(
              seleccionado
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    ),
  );
}
