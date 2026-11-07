import 'package:flutter/material.dart';

import '../../../domain/entities/estado_incidencia.dart';
import '../theme/app_colors.dart';

/// Texto, fondo y color de cada estado. También pinta los puntos del historial del detalle.
(String, Color, Color) coloresEstado(EstadoIncidencia estado) => switch (estado) {
  EstadoIncidencia.pendiente => ('Pendiente', AppColors.pendienteBg, AppColors.pendiente),
  EstadoIncidencia.asignada => ('Asignada', AppColors.asignadaBg, AppColors.asignada),
  EstadoIncidencia.enProceso => ('En proceso', AppColors.enProcesoBg, AppColors.enProceso),
  EstadoIncidencia.resuelta => ('Resuelta', AppColors.resueltaBg, AppColors.resuelta),
  EstadoIncidencia.reabierta => ('Reabierta', AppColors.reabiertaBg, AppColors.reabierta),
  EstadoIncidencia.cerrada => ('Cerrada', AppColors.cerradaBg, AppColors.cerrada),
};

/// Píldora de estado: solo texto, sin punto ni icono (design.md §7).
class EstadoChip extends StatelessWidget {
  const EstadoChip({super.key, required this.estado});

  final EstadoIncidencia estado;

  @override
  Widget build(BuildContext context) {
    final (texto, fondo, color) = coloresEstado(estado);

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: fondo, borderRadius: BorderRadius.circular(999)),
      child: Text(
        texto,
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
