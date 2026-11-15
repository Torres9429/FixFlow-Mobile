import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/operativo.dart';
import '../../core/estado_consulta.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/barra_principal.dart';
import '../../core/widgets/estado_vacio.dart';
import '../../routing/rutas.dart';
import 'personal_viewmodel.dart';

class PersonalScreen extends StatelessWidget {
  const PersonalScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: BarraPrincipal(
      accion: BotonCircular(
        key: const Key('abrir_avisos'),
        icono: Icons.notifications_outlined,
        etiqueta: 'Avisos',
        onPressed: () => context.push(Rutas.avisosAdmin),
      ),
    ),
    body: Consumer<PersonalViewModel>(
      builder: (context, vm, _) => RefreshIndicator(
        onRefresh: vm.cargar,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            _Encabezado(onNuevo: () => _abrirAlta(context, vm)),
            const SizedBox(height: 20),
            TextField(
              key: const Key('personal_busqueda'),
              onChanged: vm.buscar,
              decoration: const InputDecoration(
                hintText: 'Buscar por nombre o correo',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            _Filtros(vm: vm),
            const SizedBox(height: 20),
            ...switch (vm.estado) {
              Cargando() => const [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 36),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
              ConError(:final mensaje) => [
                EstadoVacio.error(mensaje: mensaje, onReintentar: vm.cargar),
              ],
              Listo() when vm.visibles.isEmpty => const [
                EstadoVacio(
                  icono: Icons.groups_outlined,
                  titulo: 'Sin resultados',
                  mensaje:
                      'No encontramos personal que coincida con esta búsqueda.',
                ),
              ],
              Listo() =>
                vm.visibles
                    .map(
                      (operativo) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _TarjetaOperativo(
                          operativo: operativo,
                          actualizando: vm.actualizandoId == operativo.id,
                          onCambiarEstatus: () =>
                              _confirmarEstatus(context, vm, operativo),
                        ),
                      ),
                    )
                    .toList(growable: false),
            },
          ],
        ),
      ),
    ),
  );

  Future<void> _abrirAlta(BuildContext context, PersonalViewModel vm) async {
    final creado = await context.push<bool>(Rutas.nuevoOperativo);
    if (!context.mounted || creado != true) return;
    await vm.cargar();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Operativo registrado correctamente.')),
    );
  }

  Future<void> _confirmarEstatus(
    BuildContext context,
    PersonalViewModel vm,
    Operativo operativo,
  ) async {
    final activar = !operativo.activo;
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(activar ? '¿Activar operativo?' : '¿Desactivar operativo?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              activar
                  ? '${operativo.nombreCompleto} podrá iniciar sesión y recibir nuevas incidencias.'
                  : '${operativo.nombreCompleto} no podrá recibir nuevas incidencias. Se conservará su historial y sus ${operativo.cargaActual} incidencias activas.',
            ),
            const SizedBox(height: 16),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppTheme.radius),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DatoOperativo(
                      etiqueta: 'Operativo',
                      valor: operativo.nombreCompleto,
                    ),
                    const SizedBox(height: 8),
                    _DatoOperativo(
                      etiqueta: 'Incidencias activas',
                      valor: '${operativo.cargaActual}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: activar ? null : AppColors.error,
                ),
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(
                  activar ? 'Activar operativo' : 'Desactivar operativo',
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancelar'),
              ),
            ),
          ],
        ),
      ),
    );
    if (confirmado != true || !context.mounted) return;

    final actualizado = await vm.cambiarEstatus(operativo);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          actualizado
              ? (activar ? 'Operativo activado.' : 'Operativo desactivado.')
              : vm.error ?? 'No se pudo actualizar el estado del operativo.',
        ),
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.onNuevo});

  final VoidCallback onNuevo;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Consumer<PersonalViewModel>(
      builder: (context, vm, _) {
        final activos = vm.operativos.where((item) => item.activo).length;
        final inactivos = vm.operativos.length - activos;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personal operativo',
                    style: text.headlineSmall?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${vm.operativos.length} operativos registrados ($activos activos, $inactivos inactivos)',
                    style: text.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonalIcon(
              key: const Key('personal_nuevo'),
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
      },
    );
  }
}

class _Filtros extends StatelessWidget {
  const _Filtros({required this.vm});

  final PersonalViewModel vm;

  @override
  Widget build(BuildContext context) {
    Widget filtro(String etiqueta, FiltroPersonal valor) => ChoiceChip(
      label: Text('$etiqueta (${_cantidad(valor)})'),
      selected: vm.filtro == valor,
      onSelected: (_) => vm.filtrar(valor),
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: vm.filtro == valor ? Colors.white : AppColors.textSecondary,
      ),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          filtro('Todos', FiltroPersonal.todos),
          const SizedBox(width: 8),
          filtro('Activos', FiltroPersonal.activos),
          const SizedBox(width: 8),
          filtro('Inactivos', FiltroPersonal.inactivos),
        ],
      ),
    );
  }

  int _cantidad(FiltroPersonal filtro) => switch (filtro) {
    FiltroPersonal.todos => vm.operativos.length,
    FiltroPersonal.activos => vm.operativos.where((item) => item.activo).length,
    FiltroPersonal.inactivos =>
      vm.operativos.where((item) => !item.activo).length,
  };
}

class _TarjetaOperativo extends StatelessWidget {
  const _TarjetaOperativo({
    required this.operativo,
    required this.actualizando,
    required this.onCambiarEstatus,
  });

  final Operativo operativo;
  final bool actualizando;
  final VoidCallback onCambiarEstatus;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colorEstado = operativo.activo
        ? AppColors.primaryContainer
        : AppColors.border;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        boxShadow: AppTheme.sombra,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: AppColors.primary,
                child: Text(
                  operativo.nombre.isEmpty
                      ? '?'
                      : operativo.nombre[0].toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      operativo.nombreCompleto,
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      operativo.correo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorEstado,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(operativo.activo ? 'Activo' : 'Inactivo'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${operativo.cargaActual} ${operativo.cargaActual == 1 ? 'incidencia activa' : 'incidencias activas'}',
                      style: text.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  TextButton(
                    key: Key('estatus_operativo_${operativo.id}'),
                    onPressed: actualizando ? null : onCambiarEstatus,
                    child: actualizando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(operativo.activo ? 'Desactivar' : 'Activar'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DatoOperativo extends StatelessWidget {
  const _DatoOperativo({required this.etiqueta, required this.valor});

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          etiqueta,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ),
      Text(valor, style: const TextStyle(fontWeight: FontWeight.w600)),
    ],
  );
}
