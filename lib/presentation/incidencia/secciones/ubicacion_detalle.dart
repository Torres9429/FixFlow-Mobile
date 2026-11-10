import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'seccion.dart';

/// Dirección escrita y coordenadas de la captura. El minimapa entra en el Sprint 4.
class UbicacionDetalle extends StatelessWidget {
  const UbicacionDetalle({super.key, required this.latitud, required this.longitud, this.direccion});

  final double latitud;
  final double longitud;

  /// `null` mientras se calcula o si el teléfono no pudo obtenerla: entonces solo van las coordenadas.
  final String? direccion;

  @override
  Widget build(BuildContext context) {
    final coordenadas = '${latitud.toStringAsFixed(5)}, ${longitud.toStringAsFixed(5)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TituloSeccion('Ubicación'),
        BloqueSeccion(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, size: 20, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(direccion ?? coordenadas, key: const Key('detalle_direccion'), style: estiloCuerpo(context)),
                    if (direccion != null) ...[
                      const SizedBox(height: 2),
                      Text(coordenadas, style: estiloMeta(context)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
