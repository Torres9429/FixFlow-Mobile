import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/result.dart';
import '../../../domain/entities/incidencia_detalle.dart';
import '../../core/widgets/aviso_error.dart';
import '../../core/widgets/campo_texto.dart';
import '../../incidencia/secciones/barra_acciones.dart';
import '../../incidencia/secciones/seccion.dart';
import '../../incidencia/secciones/solucion_detalle.dart';
import 'reabrir_reporte_viewmodel.dart';

/// C3 Reabrir reporte (HU-23 / RN-17): explica qué sigue mal y vuelve al detalle cuando el back responde.
class ReabrirReporteScreen extends StatefulWidget {
  const ReabrirReporteScreen({super.key, required this.detalle});

  final IncidenciaDetalle detalle;

  @override
  State<ReabrirReporteScreen> createState() => _ReabrirReporteScreenState();
}

class _ReabrirReporteScreenState extends State<ReabrirReporteScreen> {
  final _justificacion = TextEditingController();

  @override
  void dispose() {
    _justificacion.dispose();
    super.dispose();
  }

  Future<void> _enviar(BuildContext context, ReabrirReporteViewModel vm) async {
    FocusScope.of(context).unfocus();
    final res = await vm.reabrir();
    if (!context.mounted) return;
    if (res case Ok(:final value)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final meta = estiloMeta(context);
    final detalle = widget.detalle;

    return Consumer<ReabrirReporteViewModel>(
      builder: (context, vm, _) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Regresar',
            icon: const Icon(Icons.arrow_back),
            onPressed: vm.reabriendo ? null : () => context.pop(),
          ),
          title: const Text('El problema sigue'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (detalle.descripcionSolucion case final solucion?) ...[
                SolucionDetalle(
                  titulo: 'Solución anterior',
                  descripcion: solucion,
                  operativo: detalle.operativoAsignado,
                  fecha: detalle.fechaResolucion,
                ),
                const SizedBox(height: 24),
              ],
              CampoTexto(
                etiqueta: '¿Qué sigue mal?',
                child: TextFormField(
                  key: const Key('reabrir_justificacion'),
                  controller: _justificacion,
                  enabled: !vm.reabriendo,
                  minLines: 4,
                  maxLines: 6,
                  maxLength: ReabrirReporteViewModel.maxJustificacion,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: vm.cambiarJustificacion,
                  decoration: InputDecoration(
                    hintText: 'Explica qué sigue mal...',
                    counterText: '',
                    errorText: vm.errorJustificacion,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Text('Obligatorio', style: meta)),
                  Text(
                    '${vm.justificacion.length}/${ReabrirReporteViewModel.maxJustificacion}',
                    key: const Key('reabrir_contador'),
                    style: meta?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Puedes reabrir un reporte hasta 2 veces', style: meta),
              const SizedBox(height: 4),
              Text('Tu reporte pasará a Reabierta y el personal operativo verá tu motivo', style: meta),
              if (detalle.numReaperturas >= 2) ...[
                const SizedBox(height: 4),
                Text('Ya usaste las 2 reaperturas de este reporte; crea uno nuevo.', style: meta),
              ],
              if (vm.errorGeneral case final error?) ...[
                const SizedBox(height: 16),
                AvisoError(key: const Key('reabrir_error'), mensaje: error),
              ],
              const SizedBox(height: 24),
              BarraAcciones(
                primario: FilledButton(
                  key: const Key('reabrir_enviar'),
                  onPressed: vm.reabriendo || detalle.numReaperturas >= 2
                      ? null
                      : () => _enviar(context, vm),
                  child: vm.reabriendo
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Reabrir reporte'),
                ),
                secundario: OutlinedButton(
                  key: const Key('reabrir_cancelar'),
                  onPressed: vm.reabriendo ? null : () => context.pop(),
                  child: const Text('Cancelar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
