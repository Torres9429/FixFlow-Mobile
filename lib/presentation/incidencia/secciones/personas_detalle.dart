import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'seccion.dart';

/// Responsable y, solo para el admin, quién reportó (RNF-04).
class PersonasDetalle extends StatelessWidget {
  const PersonasDetalle({super.key, this.operativo, this.ciudadano});

  /// `null` mientras está Pendiente.
  final String? operativo;

  /// Se pasa solo en la vista del admin.
  final String? ciudadano;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TituloSeccion('Personas'),
        BloqueSeccion(
          child: Column(
            children: [
              _Fila(
                etiqueta: 'Responsable',
                valor: operativo ?? 'Sin asignar',
                atenuado: operativo == null,
              ),
              if (ciudadano != null) ...[
                const Divider(height: 20, color: AppColors.borderSubtle),
                _Fila(key: const Key('detalle_ciudadano'), etiqueta: 'Reportó', valor: ciudadano!),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Fila extends StatelessWidget {
  const _Fila({super.key, required this.etiqueta, required this.valor, this.atenuado = false});

  final String etiqueta;
  final String valor;
  final bool atenuado;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(etiqueta, style: estiloMeta(context)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            valor,
            textAlign: TextAlign.end,
            style: estiloCuerpo(context, color: atenuado ? AppColors.textMuted : AppColors.textPrimary)
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
