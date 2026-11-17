import 'package:flutter/material.dart';

import '../../core/formato_fecha.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'seccion.dart';

/// Foto del reporte y, si ya hay, la de la solución, en 4:3 con su fecha debajo.
/// Sin solución, la del reporte va a todo el ancho (design.md §7).
class FotosDetalle extends StatelessWidget {
  const FotosDetalle({
    super.key,
    required this.fotoReporte,
    required this.fechaReporte,
    this.fotoSolucion,
    this.fechaSolucion,
    this.sinSensor = false,
  });

  final String? fotoReporte;

  /// La foto del reporte se tomó sin acelerómetro (RN-11).
  final bool sinSensor;
  final DateTime fechaReporte;
  final String? fotoSolucion;
  final DateTime? fechaSolucion;

  @override
  Widget build(BuildContext context) {
    final reporte = _Foto(
      etiqueta: 'Reporte',
      url: fotoReporte,
      fecha: fechaReporte,
      nota: sinSensor ? 'Foto sin validación de inclinación' : null,
    );
    final conSolucion = fotoSolucion != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TituloSeccion('Fotos de evidencia', dato: conSolucion ? '2 fotos' : '1 foto'),
        if (conSolucion)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: reporte),
              const SizedBox(width: 12),
              Expanded(
                child: _Foto(etiqueta: 'Solución', url: fotoSolucion, fecha: fechaSolucion),
              ),
            ],
          )
        else
          reporte,
      ],
    );
  }
}

class _Foto extends StatelessWidget {
  const _Foto({required this.etiqueta, required this.url, required this.fecha, this.nota});

  final String etiqueta;
  final String? url;
  final DateTime? fecha;

  /// Línea extra debajo de la fecha, en meta.
  final String? nota;

  @override
  Widget build(BuildContext context) {
    const vacia = ColoredBox(color: AppColors.surfaceMuted);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (url == null)
                  vacia
                else
                  Image.network(url!, fit: BoxFit.cover, errorBuilder: (_, _, _) => vacia),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(999)),
                    child: Text(
                      etiqueta,
                      style: Theme.of(context).textTheme.labelMedium
                          ?.copyWith(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (fecha != null) ...[
          const SizedBox(height: 6),
          Text(formatearFechaCorta(fecha!), style: estiloMeta(context)),
        ],
        if (nota case final texto?) ...[
          const SizedBox(height: 2),
          Text(texto, key: const Key('foto_sin_sensor'), style: estiloMeta(context)),
        ],
      ],
    );
  }
}
