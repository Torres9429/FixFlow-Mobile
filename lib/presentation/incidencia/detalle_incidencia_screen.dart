import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/estado_consulta.dart';
import '../core/widgets/esqueleto_tarjetas.dart';
import '../core/widgets/estado_vacio.dart';
import '../routing/rutas.dart';
import 'detalle_incidencia_viewmodel.dart';
import 'secciones/barra_acciones.dart';
import 'secciones/encabezado_detalle.dart';
import 'secciones/fotos_detalle.dart';
import 'secciones/historial_detalle.dart';
import 'secciones/personas_detalle.dart';
import 'secciones/solucion_detalle.dart';
import 'secciones/ubicacion_detalle.dart';

/// C2, D2 y E4: la misma pantalla; cambia el título y si se ve quién reportó.
class DetalleIncidenciaScreen extends StatelessWidget {
  const DetalleIncidenciaScreen({super.key});

  static const _separacion = SizedBox(height: 24);

  @override
  Widget build(BuildContext context) {
    final vm = context.read<DetalleIncidenciaViewModel>();

    return Scaffold(
      appBar: AppBar(title: Text(vm.vista.titulo)),
      // Sin acción válida no hay barra (design.md §7)
      bottomNavigationBar: Consumer<DetalleIncidenciaViewModel>(
        builder: (context, vm, _) => vm.puedeAsignar
            ? BarraAcciones(
                primario: FilledButton(
                  key: const Key('detalle_asignar'),
                  onPressed: () async {
                    await context.push(Rutas.asignarAdmin(vm.id));
                    // Al volver de E5 la incidencia ya puede estar Asignada
                    await vm.iniciar();
                  },
                  child: Text(vm.tieneResponsable ? 'Reasignar' : 'Asignar'),
                ),
              )
            : const SizedBox.shrink(),
      ),
      body: Consumer<DetalleIncidenciaViewModel>(
        builder: (context, vm, _) => switch (vm.estado) {
          Cargando() => const Padding(padding: EdgeInsets.all(20), child: EsqueletoTarjetas()),
          ConError(:final mensaje) => ListView(
            children: [EstadoVacio.error(mensaje: mensaje, onReintentar: vm.iniciar)],
          ),
          Listo(:final datos) => RefreshIndicator(
            onRefresh: vm.iniciar,
            child: ListView(
              key: const Key('detalle_incidencia'),
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                EncabezadoDetalle(detalle: datos.detalle),
                _separacion,
                UbicacionDetalle(
                  latitud: datos.detalle.resumen.latitud,
                  longitud: datos.detalle.resumen.longitud,
                  direccion: vm.direccion,
                ),
                _separacion,
                FotosDetalle(
                  fotoReporte: datos.detalle.fotoReporteUrl,
                  fechaReporte: datos.detalle.resumen.fechaCreacion,
                  fotoSolucion: datos.detalle.fotoSolucionUrl,
                  fechaSolucion: datos.detalle.fechaResolucion,
                ),
                if (datos.detalle.descripcionSolucion case final solucion?) ...[
                  _separacion,
                  SolucionDetalle(
                    descripcion: solucion,
                    operativo: datos.detalle.operativoAsignado,
                    fecha: datos.detalle.fechaResolucion,
                  ),
                ],
                if (datos.detalle.motivoReapertura case final motivo?) ...[
                  _separacion,
                  ReaperturaDetalle(motivo: motivo, veces: datos.detalle.numReaperturas),
                ],
                _separacion,
                PersonasDetalle(
                  operativo: datos.detalle.operativoAsignado,
                  ciudadano: vm.mostrarCiudadano ? datos.detalle.ciudadano : null,
                ),
                _separacion,
                HistorialDetalle(eventos: vm.eventosVisibles, hayMas: vm.hayMas, onVerTodo: vm.mostrarTodo),
              ],
            ),
          ),
        },
      ),
    );
  }
}
