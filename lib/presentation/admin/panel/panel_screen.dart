import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/incidencia_resumen.dart';
import '../../../domain/entities/indicadores.dart';
import '../../../domain/entities/prioridad.dart';
import '../../core/estado_consulta.dart';
import '../../core/formato_fecha.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/barra_principal.dart';
import '../../core/widgets/esqueleto_tarjetas.dart';
import '../../core/widgets/estado_vacio.dart';
import '../../core/widgets/incidencia_card.dart';
import '../../core/widgets/lista_incidencias.dart';
import '../../core/widgets/saludo.dart';
import '../../routing/rutas.dart';
import 'panel_viewmodel.dart';

/// E1 Panel (pestaña Inicio del admin).
class PanelScreen extends StatelessWidget {
  const PanelScreen({super.key});

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
      body: Consumer<PanelViewModel>(
        builder: (context, vm, _) => ListaIncidencias(
          onRecargar: vm.cargar,
          encabezado: [
            Saludo(nombre: vm.nombre, subtitulo: 'Panel del municipio'),
            const SizedBox(height: 16),
          ],
          contenido: _contenido(context, vm),
        ),
      ),
    );
  }

  List<Widget> _contenido(BuildContext context, PanelViewModel vm) => switch (vm.estado) {
    Cargando() => const [Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: EsqueletoTarjetas())],
    ConError(:final mensaje) => [EstadoVacio.error(mensaje: mensaje, onReintentar: vm.cargar)],
    Listo(datos: (:final indicadores, :final prioritarias)) => _panel(context, indicadores, prioritarias),
  };

  List<Widget> _panel(BuildContext context, Indicadores indicadores, List<IncidenciaResumen> prioritarias) {
    final texto = Theme.of(context).textTheme;
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Cifras(indicadores: indicadores),
            const SizedBox(height: 12),
            _TiempoYPrioridad(indicadores: indicadores),
            const SizedBox(height: 12),
            const _FilaCatalogo(),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Prioridad alta sin atender',
                    style: texto.titleMedium?.copyWith(fontSize: 17, height: 24 / 17, fontWeight: FontWeight.w700),
                  ),
                ),
                TextButton(onPressed: () => context.go(Rutas.incidenciasAdmin), child: const Text('Ver todas')),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      if (prioritarias.isEmpty)
        const EstadoVacio(
          icono: Icons.inbox_outlined,
          titulo: 'Todo en orden',
          mensaje: 'No hay incidencias de prioridad alta esperando asignación.',
        )
      else
        ...conSeparacion(
          prioritarias.map(
            (i) => IncidenciaCard(
              incidencia: i,
              meta: '${i.folio} · ${formatearFechaCorta(i.ultimaActualizacion)}',
              onTap: () => context.push(Rutas.detalleAdmin(i.id)),
            ),
          ),
        ),
    ];
  }
}

/// Tarjeta blanca con sombra, sin borde.
class _Tarjeta extends StatelessWidget {
  const _Tarjeta({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        boxShadow: AppTheme.sombra,
      ),
      child: child,
    );
  }
}

/// Registradas · Pendientes · En atención · Atendidas, en 2 × 2 y sin color (design.md, E1).
class _Cifras extends StatelessWidget {
  const _Cifras({required this.indicadores});

  final Indicadores indicadores;

  @override
  Widget build(BuildContext context) {
    Widget cifra(String etiqueta, int valor) => Expanded(
      child: _Tarjeta(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(valor.toString(), style: _estiloCifra(context)),
            const SizedBox(height: 4),
            Text(etiqueta, style: _estiloMeta(context)),
          ],
        ),
      ),
    );

    return Column(
      children: [
        Row(
          children: [
            cifra('Registradas', indicadores.registradas),
            const SizedBox(width: 12),
            cifra('Pendientes', indicadores.pendientes),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            cifra('En atención', indicadores.enAtencion),
            const SizedBox(width: 12),
            cifra('Atendidas', indicadores.atendidas),
          ],
        ),
      ],
    );
  }
}

class _TiempoYPrioridad extends StatelessWidget {
  const _TiempoYPrioridad({required this.indicadores});

  final Indicadores indicadores;

  String _horas(double? h) => h == null ? '—' : '${h.round()} h';

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final conteo = indicadores.porPrioridad;
    final total = conteo.values.fold(0, (a, b) => a + b);
    const colores = {
      Prioridad.alta: AppColors.prioridadAlta,
      Prioridad.media: AppColors.prioridadMedia,
      Prioridad.baja: AppColors.prioridadBaja,
    };
    const nombres = {Prioridad.alta: 'Alta', Prioridad.media: 'Media', Prioridad.baja: 'Baja'};

    return _Tarjeta(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Tiempo de resolución', style: texto.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_horas(indicadores.resolucionPromedioHoras), style: _estiloCifra(context)),
                    Text('Promedio', style: _estiloMeta(context)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_horas(indicadores.resolucionMaxHoras), style: _estiloCifra(context)),
                    Text('Máximo', style: _estiloMeta(context)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Por prioridad', style: texto.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          // Barra apilada con los 3 colores de prioridad
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 12,
              child: total == 0
                  ? const ColoredBox(color: AppColors.borderSubtle)
                  : Row(
                      children: [
                        for (final p in Prioridad.values)
                          if ((conteo[p] ?? 0) > 0)
                            Expanded(
                              flex: conteo[p]!,
                              child: ColoredBox(color: colores[p]!),
                            ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final p in Prioridad.values) ...[
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: colores[p], shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text('${nombres[p]} ${conteo[p] ?? 0}', style: _estiloMeta(context)),
                const SizedBox(width: 16),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Acceso a E10: título, «Gestionar catálogo de tipos, 9 activos / 1 inactivo» y chevron en un círculo.
class _FilaCatalogo extends StatelessWidget {
  const _FilaCatalogo();

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final vm = context.watch<PanelViewModel>();
    final radio = BorderRadius.circular(AppTheme.radius);
    final subtitulo = vm.resumenCatalogo == null
        ? 'Gestionar catálogo de tipos'
        : 'Gestionar catálogo de tipos, ${vm.resumenCatalogo}';

    // La sombra va por fuera del Material: dentro de él se recorta o tapa la tarjeta
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: radio, boxShadow: AppTheme.sombra),
      child: Material(
        color: AppColors.surface,
        borderRadius: radio,
        child: InkWell(
          key: const Key('abrir_catalogo'),
          borderRadius: radio,
          onTap: () async {
            await context.push(Rutas.catalogoTipos);
            // Al volver, las cifras pueden haber cambiado
            await vm.cargarCatalogo();
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Catálogo de tipos', style: texto.titleMedium?.copyWith(fontSize: 17, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(subtitulo, style: _estiloMeta(context)?.copyWith(fontSize: 14, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(color: AppColors.surfaceMuted, shape: BoxShape.circle),
                  child: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

TextStyle? _estiloCifra(BuildContext context) => Theme.of(context).textTheme.headlineSmall?.copyWith(
  fontSize: 24,
  height: 30 / 24,
  fontWeight: FontWeight.w800,
  fontFeatures: const [FontFeature.tabularFigures()],
);

TextStyle? _estiloMeta(BuildContext context) =>
    Theme.of(context).textTheme.bodySmall
        ?.copyWith(fontSize: 13, height: 18 / 13, fontWeight: FontWeight.w500, color: AppColors.textMuted);
