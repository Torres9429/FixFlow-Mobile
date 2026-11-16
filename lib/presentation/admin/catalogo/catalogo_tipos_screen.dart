import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/tipo_incidencia.dart';
import '../../core/estado_consulta.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/esqueleto_tarjetas.dart';
import '../../core/widgets/estado_vacio.dart';
import '../../core/widgets/prioridad_simbolo.dart';
import '../../routing/rutas.dart';
import 'catalogo_tipos_viewmodel.dart';
import 'confirmar_estatus_tipo.dart';
import 'textos_tipo.dart';

/// E10 Catálogo de tipos, con la misma estructura que E8 Personal operativo.
/// Se abre desde E1, así que no lleva barra inferior.
class CatalogoTiposScreen extends StatelessWidget {
  const CatalogoTiposScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Consumer<CatalogoTiposViewModel>(
        builder: (context, vm, _) => RefreshIndicator(
          onRefresh: vm.cargar,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            children: [
              _Encabezado(vm: vm, onNuevo: () => _abrir(context, vm, Rutas.nuevoTipo)),
              const SizedBox(height: 20),
              _Filtros(vm: vm),
              const SizedBox(height: 20),
              ...switch (vm.estado) {
                Cargando() => const [EsqueletoTarjetas()],
                ConError(:final mensaje) => [EstadoVacio.error(mensaje: mensaje, onReintentar: vm.cargar)],
                Listo() when vm.visibles.isEmpty => const [
                  EstadoVacio(
                    icono: Icons.category_outlined,
                    titulo: 'Sin tipos',
                    mensaje: 'No hay tipos en este filtro.',
                  ),
                ],
                Listo() => [
                  for (final tipo in vm.visibles)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _TarjetaTipo(
                        tipo: tipo,
                        actualizando: vm.actualizandoId == tipo.id,
                        onTap: () => _abrir(context, vm, Rutas.editarTipo, extra: tipo),
                        onCambiarEstatus: () => _cambiarEstatus(context, vm, tipo),
                      ),
                    ),
                ],
              },
            ],
          ),
        ),
      ),
    );
  }

  /// E11 y E12 regresan `true` si guardaron algo.
  Future<void> _abrir(BuildContext context, CatalogoTiposViewModel vm, String ruta, {Object? extra}) async {
    final cambio = await context.push<bool>(ruta, extra: extra);
    if (cambio == true) await vm.cargar();
  }

  Future<void> _cambiarEstatus(BuildContext context, CatalogoTiposViewModel vm, TipoIncidencia tipo) async {
    if (!await confirmarEstatusTipo(context, tipo) || !context.mounted) return;
    final ok = await vm.cambiarEstatus(tipo);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? avisoEstatusTipo(tipo) : vm.error ?? 'No se pudo cambiar el estado del tipo.')),
    );
  }
}

/// Título, cuántos tipos hay y el botón «Nuevo», como en personal operativo.
class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.vm, required this.onNuevo});

  final CatalogoTiposViewModel vm;
  final VoidCallback onNuevo;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final total = vm.tipos.length;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Catálogo de tipos', style: texto.headlineSmall?.copyWith(fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(
                vm.estado is Listo
                    ? '$total ${total == 1 ? 'tipo registrado' : 'tipos registrados'} '
                          '(${vm.activos} ${vm.activos == 1 ? 'activo' : 'activos'}, '
                          '${vm.inactivos} ${vm.inactivos == 1 ? 'inactivo' : 'inactivos'})'
                    : 'Prioridad base y orientación de la cámara de cada tipo',
                style: texto.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        FilledButton.tonalIcon(
          key: const Key('agregar_tipo'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryContainer,
            foregroundColor: AppColors.textSecondary,
            minimumSize: const Size(0, 44),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            shape: const StadiumBorder(),
          ),
          onPressed: onNuevo,
          icon: const Icon(Icons.add),
          label: const Text('Nuevo'),
        ),
      ],
    );
  }
}

/// Todos · Activos · Inactivos, con su cantidad, como en personal operativo.
class _Filtros extends StatelessWidget {
  const _Filtros({required this.vm});

  final CatalogoTiposViewModel vm;

  @override
  Widget build(BuildContext context) {
    Widget filtro(String etiqueta, FiltroTipos valor) => ChoiceChip(
      key: Key('filtro_tipos_${valor.name}'),
      label: Text('$etiqueta (${vm.cantidad(valor)})'),
      selected: vm.filtro == valor,
      onSelected: (_) => vm.filtrar(valor),
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(color: vm.filtro == valor ? Colors.white : AppColors.textSecondary),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          filtro('Todos', FiltroTipos.todos),
          const SizedBox(width: 8),
          filtro('Activos', FiltroTipos.activos),
          const SizedBox(width: 8),
          filtro('Inactivos', FiltroTipos.inactivos),
        ],
      ),
    );
  }
}

/// Como la tarjeta de un operativo: arriba el nombre con su píldora Activo/Inactivo,
/// en medio la prioridad y la orientación, y abajo una franja con cuántas incidencias lo usan y la acción.
class _TarjetaTipo extends StatelessWidget {
  const _TarjetaTipo({
    required this.tipo,
    required this.actualizando,
    required this.onTap,
    required this.onCambiarEstatus,
  });

  final TipoIncidencia tipo;
  final bool actualizando;
  final VoidCallback onTap;
  final VoidCallback onCambiarEstatus;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final inactivo = !tipo.activo;
    final radio = BorderRadius.circular(AppTheme.radius);

    // La sombra va por fuera del Material; el borde ayuda a separar la tarjeta del fondo blanco
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: radio, boxShadow: AppTheme.sombra),
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: radio, side: const BorderSide(color: AppColors.borderSubtle)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: Key('tipo_${tipo.id}'),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: inactivo ? AppColors.campoBloqueado : AppColors.primaryContainer,
                      foregroundColor: inactivo ? AppColors.textMuted : AppColors.primary,
                      child: Icon(_iconoOrientacion(tipo.orientacion), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tipo.nombre,
                            style: texto.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: inactivo ? AppColors.textMuted : AppColors.textPrimary,
                              decoration: inactivo ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          Text(tipo.codigo, style: texto.bodySmall?.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: inactivo ? AppColors.border : AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(inactivo ? 'Inactivo' : 'Activo'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Opacity(opacity: inactivo ? 0.4 : 1, child: PrioridadSimbolo(prioridad: tipo.prioridadBase)),
                    const SizedBox(width: 6),
                    Text(
                      'Prioridad ${textoPrioridad(tipo.prioridadBase).toLowerCase()}',
                      style: texto.bodyMedium?.copyWith(color: AppColors.textSecondary),
                    ),
                    Text('  ·  ', style: texto.bodyMedium?.copyWith(color: AppColors.textMuted)),
                    Expanded(
                      child: Text(
                        textoOrientacionConRango(tipo),
                        style: texto.bodyMedium?.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
                if (inactivo) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Desactivado: no aparece en reportes nuevos',
                    style: texto.bodySmall?.copyWith(color: AppColors.textMuted),
                  ),
                ],
                const SizedBox(height: 14),
                DecoratedBox(
                  decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.assignment_outlined, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            textoIncidencias(tipo.incidencias ?? 0),
                            style: texto.bodyMedium?.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                        TextButton(
                          key: Key('estatus_tipo_${tipo.id}'),
                          onPressed: actualizando ? null : onCambiarEstatus,
                          child: actualizando
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : Text(inactivo ? 'Activar' : 'Desactivar'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static IconData _iconoOrientacion(OrientacionFoto o) => switch (o) {
    OrientacionFoto.suelo => Icons.arrow_downward,
    OrientacionFoto.arriba => Icons.arrow_upward,
    OrientacionFoto.sinRestriccion => Icons.swap_horiz,
  };
}
