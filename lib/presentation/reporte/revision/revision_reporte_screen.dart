import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/formato_fecha.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../routing/rutas.dart';
import 'revision_reporte_viewmodel.dart';

/// B4 Revisar y enviar, paso 2 de 2. «Repetir foto» regresa a B2 con `true` para volver a abrir la cámara.
class RevisionReporteScreen extends StatelessWidget {
  const RevisionReporteScreen({super.key});

  static String _coordenadas(double lat, double lng) =>
      '${lat.abs().toStringAsFixed(4)}° ${lat >= 0 ? 'N' : 'S'}, '
      '${lng.abs().toStringAsFixed(4)}° ${lng >= 0 ? 'E' : 'W'}';

  Future<void> _enviar(BuildContext context, RevisionReporteViewModel vm) async {
    await vm.enviar();
    if (!context.mounted) return;
    final creado = vm.creado;
    // `go` reemplaza la pila: desde B5 no se puede regresar a B4
    if (creado != null) context.go(Rutas.reporteEnviado, extra: creado);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RevisionReporteViewModel>();
    final reporte = vm.reporte;
    final texto = Theme.of(context).textTheme;
    final meta = texto.bodySmall?.copyWith(
      fontSize: 13,
      height: 18 / 13,
      fontWeight: FontWeight.w500,
      color: AppColors.textMuted,
    );
    final tituloTarjeta = texto.titleMedium?.copyWith(fontSize: 16, height: 22 / 16, fontWeight: FontWeight.w700);
    final enlace = TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      minimumSize: const Size(48, 36),
      textStyle: texto.bodySmall?.copyWith(fontSize: 13, fontWeight: FontWeight.w700),
    );
    final inclinacion = reporte.inclinacion;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Regresar',
          icon: const Icon(Icons.arrow_back),
          onPressed: vm.ocupado ? null : () => Navigator.of(context).pop(),
        ),
        title: const Text('Revisar y enviar'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text('Paso 2 de 2', style: meta?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          // Foto con la etiqueta de evidencia en vivo
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radius),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(File(reporte.rutaFoto), fit: BoxFit.cover),
                  Positioned(top: 12, left: 12, child: _EtiquetaEnVivo(estilo: texto.labelMedium)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  [
                    'Capturada ${formatearFechaCorta(reporte.capturadaEn)}',
                    if (inclinacion != null) 'Inclinación ${inclinacion.round()}°',
                  ].join(' · '),
                  style: meta,
                ),
              ),
              TextButton(
                key: const Key('reporte_repetir_foto'),
                style: enlace,
                onPressed: vm.ocupado ? null : () => Navigator.of(context).pop(true),
                child: const Text('Repetir foto'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Tarjeta(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tipo de incidencia', style: meta),
                const SizedBox(height: 2),
                Text(reporte.tipo.nombre, style: tituloTarjeta),
                const SizedBox(height: 8),
                Text(
                  reporte.descripcion,
                  style: texto.bodyLarge?.copyWith(fontSize: 15, height: 22 / 15, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                Text('Fecha, hora y folio se asignan al enviar', style: meta),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Tarjeta(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ubicación detectada', style: meta),
                const SizedBox(height: 2),
                // La dirección escrita llega con `geocoding` (design.md §2)
                Text('Dirección no disponible', style: tituloTarjeta),
                const SizedBox(height: 8),
                const _MiniMapaProvisional(),
                const SizedBox(height: 12),
                Text(
                  _coordenadas(reporte.latitud, reporte.longitud),
                  style: meta?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                ),
                const SizedBox(height: 4),
                Text('La ubicación se toma del GPS y no se puede editar', style: meta),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BarraEnvio(vm: vm, onEnviar: () => _enviar(context, vm)),
    );
  }
}

/// Barra fija de abajo: el motivo o error en rojo y la única acción que sirve en ese momento.
class _BarraEnvio extends StatelessWidget {
  const _BarraEnvio({required this.vm, required this.onEnviar});

  final RevisionReporteViewModel vm;
  final VoidCallback onEnviar;

  @override
  Widget build(BuildContext context) {
    final problema = vm.problema;
    // Con la evidencia inválida (aquí o en el back) reintentar no sirve: hay que volver a capturar
    final volverACapturar = problema != null || vm.pideRepetir;
    final aviso = problema ?? vm.error;

    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.surface, boxShadow: AppTheme.sombraBarraInferior),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (aviso != null) ...[
                Text(
                  aviso,
                  key: const Key('reporte_aviso'),
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(fontSize: 13, height: 18 / 13, color: AppColors.error),
                ),
                const SizedBox(height: 12),
              ],
              if (volverACapturar)
                FilledButton(
                  key: const Key('reporte_volver_a_capturar'),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Volver a capturar'),
                )
              else
                FilledButton(
                  key: const Key('reporte_confirmar'),
                  onPressed: vm.ocupado ? null : onEnviar,
                  child: switch (vm.paso) {
                    PasoEnvio.listo => Text(vm.error == null ? 'Enviar reporte' : 'Reintentar'),
                    PasoEnvio.subiendoFoto => const _Progreso(texto: 'Subiendo foto…'),
                    PasoEnvio.enviando => const _Progreso(texto: 'Enviando…'),
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Progreso extends StatelessWidget {
  const _Progreso({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2.5)),
        const SizedBox(width: 12),
        Text(texto),
      ],
    );
  }
}

class _Tarjeta extends StatelessWidget {
  const _Tarjeta({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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

/// Píldora blanca con punto verde sobre la foto.
class _EtiquetaEnVivo extends StatelessWidget {
  const _EtiquetaEnVivo({required this.estilo});

  final TextStyle? estilo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        boxShadow: AppTheme.sombra,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: AppColors.resuelta, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            'Evidencia en vivo',
            style: estilo?.copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

/// Lugar del minimapa de 160 con el punto de la captura; el mapa real todavía no está.
class _MiniMapaProvisional extends StatelessWidget {
  const _MiniMapaProvisional();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppTheme.radius)),
      alignment: Alignment.center,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
        child: const Icon(Icons.location_on, size: 20, color: Colors.white),
      ),
    );
  }
}
