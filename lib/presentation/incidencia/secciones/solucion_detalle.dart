import 'package:flutter/material.dart';

import '../../core/formato_fecha.dart';
import 'seccion.dart';

/// La solución que registró el operativo (C2 la muestra antes de confirmar).
class SolucionDetalle extends StatelessWidget {
  const SolucionDetalle({super.key, required this.descripcion, this.operativo, this.fecha});

  final String descripcion;
  final String? operativo;
  final DateTime? fecha;

  @override
  Widget build(BuildContext context) {
    final meta = [?operativo, if (fecha != null) formatearFechaCorta(fecha!)].join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TituloSeccion('Solución'),
        BloqueSeccion(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(descripcion, style: estiloCuerpo(context)),
              if (meta.isNotEmpty) ...[const SizedBox(height: 6), Text(meta, style: estiloMeta(context))],
            ],
          ),
        ),
      ],
    );
  }
}

/// Por qué el ciudadano reabrió la incidencia (RN-14). Se reutiliza en D4.
class ReaperturaDetalle extends StatelessWidget {
  const ReaperturaDetalle({super.key, required this.motivo, required this.veces});

  final String motivo;
  final int veces;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TituloSeccion('Motivo de la reapertura', dato: veces == 1 ? '1 reapertura' : '$veces reaperturas'),
        BloqueSeccion(child: Text(motivo, style: estiloCuerpo(context))),
      ],
    );
  }
}
