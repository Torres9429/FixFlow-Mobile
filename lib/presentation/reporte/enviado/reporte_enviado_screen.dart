import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/prioridad.dart';
import '../../../domain/entities/reporte_creado.dart';
import '../../core/formato_fecha.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../routing/rutas.dart';

/// B5 Reporte enviado: el folio que generó el servidor (RN-08). No se puede regresar a B4.
class ReporteEnviadoScreen extends StatelessWidget {
  const ReporteEnviadoScreen({super.key, required this.reporte});

  final ReporteCreado reporte;

  /// B1 con un parámetro nuevo: así se crea otro ViewModel y aparece el reporte recién enviado.
  void _irAMisReportes(BuildContext context) =>
      context.go('${Rutas.homeCiudadano}?recargar=${DateTime.now().millisecondsSinceEpoch}');

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final prioridad = switch (reporte.prioridad) {
      Prioridad.alta => 'Alta',
      Prioridad.media => 'Media',
      Prioridad.baja => 'Baja',
    };

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _irAMisReportes(context);
      },
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            children: [
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(color: AppColors.resueltaBg, shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle, size: 36, color: AppColors.resuelta),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Reporte registrado',
                textAlign: TextAlign.center,
                style: texto.headlineSmall?.copyWith(fontSize: 24, height: 30 / 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Se notificará al área operativa municipal para su programación y atención. '
                'Te avisaremos cada vez que cambie de estado.',
                textAlign: TextAlign.center,
                style: texto.bodyLarge?.copyWith(fontSize: 15, height: 22 / 15, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              _TarjetaFolio(folio: reporte.folio),
              const SizedBox(height: 16),
              _Tarjeta(
                child: Column(
                  children: [
                    _Fila(etiqueta: 'Tipo de reporte', valor: reporte.tipo),
                    const Divider(height: 24, color: AppColors.borderSubtle),
                    _Fila(etiqueta: 'Prioridad asignada', valor: '$prioridad (por tipo)'),
                    const Divider(height: 24, color: AppColors.borderSubtle),
                    _Fila(etiqueta: 'Fecha de registro', valor: formatearFechaCorta(reporte.fechaCreacion)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // «Ver mi reporte» (C2) se agrega cuando exista el detalle de la incidencia
              FilledButton(
                key: const Key('reporte_ir_a_mis_reportes'),
                onPressed: () => _irAMisReportes(context),
                child: const Text('Ir a Mis reportes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Folio en grande, con la franja azul arriba.
class _TarjetaFolio extends StatelessWidget {
  const _TarjetaFolio({required this.folio});

  final String folio;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radius),
      child: DecoratedBox(
        decoration: const BoxDecoration(color: AppColors.surface, boxShadow: AppTheme.sombra),
        child: Column(
          children: [
            const SizedBox(
              height: 4,
              width: double.infinity,
              child: ColoredBox(color: AppColors.primary),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                children: [
                  Text(
                    'Folio de seguimiento',
                    style: texto.labelMedium?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    folio,
                    key: const Key('reporte_folio'),
                    style: texto.headlineSmall?.copyWith(
                      fontSize: 26,
                      height: 32 / 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

class _Fila extends StatelessWidget {
  const _Fila({required this.etiqueta, required this.valor});

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            etiqueta,
            style: texto.bodyLarge?.copyWith(fontSize: 15, height: 22 / 15, color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          valor,
          style: texto.bodyLarge?.copyWith(fontSize: 15, height: 22 / 15, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
