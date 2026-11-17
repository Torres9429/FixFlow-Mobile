import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/estado_incidencia.dart';
import '../../../domain/entities/incidencia_resumen.dart';
import '../../../domain/entities/prioridad.dart';
import '../../core/estado_consulta.dart';
import '../../core/formato_fecha.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/barra_principal.dart';
import '../../core/widgets/chips_filtro.dart';
import '../../core/widgets/esqueleto_tarjetas.dart';
import '../../core/widgets/estado_vacio.dart';
import '../../core/widgets/incidencia_card.dart';
import '../../core/widgets/lista_incidencias.dart';
import '../../routing/rutas.dart';
import 'incidencias_admin_viewmodel.dart';

/// E2 Incidencias del municipio (HU-17).
class IncidenciasAdminScreen extends StatelessWidget {
  const IncidenciasAdminScreen({super.key});

  static const _filtros = <(EstadoIncidencia?, String)>[
    (null, 'Todas'),
    (EstadoIncidencia.pendiente, 'Pendientes'),
    (EstadoIncidencia.asignada, 'Asignadas'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BarraPrincipal(
        accion: BotonCircular(
          key: const Key('abrir_avisos'),
          icono: Icons.notifications_outlined,
          etiqueta: 'Avisos',
          onPressed: () => context.push(Rutas.avisosAdmin),
        ),
      ),
      body: Consumer<IncidenciasAdminViewModel>(
        builder: (context, vm, _) => ListaIncidencias(
          onRecargar: vm.cargar,
          onFinal: vm.cargarMas,
          encabezado: [_Encabezado(vm: vm, filtros: _filtros)],
          contenido: _contenido(context, vm),
        ),
      ),
    );
  }

  List<Widget> _contenido(BuildContext context, IncidenciasAdminViewModel vm) => switch (vm.estado) {
    Cargando() => const [Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: EsqueletoTarjetas())],
    ConError(:final mensaje) => [EstadoVacio.error(mensaje: mensaje, onReintentar: vm.cargar)],
    Listo() when vm.visibles.isEmpty => const [
      EstadoVacio(
        icono: Icons.inbox_outlined,
        titulo: 'Sin incidencias',
        mensaje: 'No hay incidencias que coincidan con la búsqueda o los filtros elegidos.',
      ),
    ],
    Listo() => _lista(context, vm),
  };

  List<Widget> _lista(BuildContext context, IncidenciasAdminViewModel vm) => [
    ...conSeparacion(
      vm.visibles.map(
        (i) => IncidenciaCard(
          incidencia: i,
          meta: '${i.folio} · ${formatearFechaCorta(i.ultimaActualizacion)}',
          onTap: () => _abrir(context, vm, i),
        ),
      ),
    ),
    if (vm.cargandoMas)
      const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
    const _Pie(),
  ];

  /// Pendiente → directo a asignar (E5); el resto → ficha (E4).
  /// Al volver se recarga: la incidencia pudo cambiar de estado.
  Future<void> _abrir(BuildContext context, IncidenciasAdminViewModel vm, IncidenciaResumen i) async {
    if (i.estado == EstadoIncidencia.pendiente) {
      await context.push(Rutas.asignarAdmin(i.id));
    } else {
      await context.push(Rutas.detalleAdmin(i.id));
    }
    if (!context.mounted) return;
    await vm.iniciar();
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.vm, required this.filtros});

  final IncidenciasAdminViewModel vm;
  final List<(EstadoIncidencia?, String)> filtros;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final conDatos = vm.estado is Listo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Incidencias del municipio',
                style: texto.headlineSmall?.copyWith(fontSize: 24, height: 30 / 24, fontWeight: FontWeight.w800),
              ),
              if (conDatos) ...[
                const SizedBox(height: 4),
                Text(
                  '${vm.incidencias.length} incidencias registradas en la demarcación',
                  style: texto.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('incidencias_busqueda'),
                  onChanged: vm.buscar,
                  decoration: const InputDecoration(
                    hintText: 'Buscar por folio (FX-...), calle o tipo',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Solo abre la vista de los filtros de abajo (HU-18 hará la zona)
              BotonCircular(
                key: const Key('incidencias_filtros'),
                icono: Icons.tune,
                etiqueta: 'Filtros',
                onPressed: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ChipsFiltro<EstadoIncidencia?>(
          opciones: [
            for (final (valor, etiqueta) in filtros) (valor, '$etiqueta (${vm.contar(valor)})'),
          ],
          seleccionada: vm.filtro,
          onSeleccionar: vm.cambiarFiltro,
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _Desplegable(
                id: 'prioridad',
                etiqueta: 'Prioridad',
                valor: _clavePrioridad(vm.prioridad),
                opciones: const [
                  ('', 'Todas'),
                  ('alta', 'Alta'),
                  ('media', 'Media'),
                  ('baja', 'Baja'),
                ],
                onCambio: (clave) => vm.cambiarPrioridad(_prioridadDe(clave)),
              ),
              const SizedBox(width: 8),
              _Desplegable(
                id: 'tipo',
                etiqueta: 'Tipo',
                valor: vm.tipoId,
                opciones: [
                  ('', 'Todos'),
                  for (final tipo in vm.tipos) (tipo.id, tipo.nombre),
                ],
                onCambio: vm.cambiarTipo,
              ),
              const SizedBox(width: 8),
              // La zona llega en HU-18: por ahora se ve pero no se puede elegir
              const _Desplegable(
                id: 'zona',
                etiqueta: 'Zona',
                valor: '5 km',
                opciones: [('5 km', '5 km')],
                habilitado: false,
                onCambio: _ignorar,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void _ignorar(String _) {}

String _clavePrioridad(Prioridad? p) => switch (p) {
  null => '',
  Prioridad.alta => 'alta',
  Prioridad.media => 'media',
  Prioridad.baja => 'baja',
};

Prioridad? _prioridadDe(String clave) => switch (clave) {
  'alta' => Prioridad.alta,
  'media' => Prioridad.media,
  'baja' => Prioridad.baja,
  _ => null,
};

class _Desplegable extends StatelessWidget {
  const _Desplegable({
    required this.id,
    required this.etiqueta,
    required this.valor,
    required this.opciones,
    required this.onCambio,
    this.habilitado = true,
  });

  final String id;
  final String etiqueta;
  final String valor;
  final List<(String, String)> opciones;
  final ValueChanged<String> onCambio;
  final bool habilitado;

  @override
  Widget build(BuildContext context) {
    final radio = BorderRadius.circular(AppTheme.radius);
    final estilo = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontSize: 12,
      height: 16 / 12,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
    );

    return Expanded(
      child: Container(
        key: Key('filtro_$id'),
        decoration: BoxDecoration(
          color: habilitado ? AppColors.surface : AppColors.campoBloqueado,
          borderRadius: radio,
          border: Border.all(color: habilitado ? AppColors.border : AppColors.borderSubtle, width: 1.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: DropdownButton<String>(
          value: valor,
          isExpanded: true,
          isDense: true,
          underline: const SizedBox.shrink(),
          style: estilo,
          items: [
            for (final (clave, texto) in opciones)
              DropdownMenuItem(
                value: clave,
                child: Text(texto, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
          ],
          selectedItemBuilder: (context) => [
            for (final (_, texto) in opciones)
              Text(
                '$etiqueta: $texto',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: estilo,
              ),
          ],
          onChanged: habilitado
              ? (v) {
                  if (v != null) onCambio(v);
                }
              : null,
        ),
      ),
    );
  }
}

/// «Todas las incidencias del cuadrante sincronizadas», al final de la lista (design.md, E2).
class _Pie extends StatelessWidget {
  const _Pie();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sync, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Text(
            'Todas las incidencias del cuadrante sincronizadas',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 13,
              height: 18 / 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
