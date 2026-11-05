import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/estado_incidencia.dart';
import '../../core/estado_consulta.dart';
import '../../core/formato_fecha.dart';
import '../../core/widgets/barra_principal.dart';
import '../../core/widgets/chips_filtro.dart';
import '../../core/widgets/esqueleto_tarjetas.dart';
import '../../core/widgets/estado_vacio.dart';
import '../../core/widgets/incidencia_card.dart';
import '../../core/widgets/lista_incidencias.dart';
import '../../core/widgets/saludo.dart';
import '../../routing/rutas.dart';
import 'mis_reportes_viewmodel.dart';

/// B1 Mis reportes, o C4 si el ciudadano todavía no tiene ninguno.
class MisReportesScreen extends StatelessWidget {
  const MisReportesScreen({super.key});

  static const _filtros = <(EstadoIncidencia?, String)>[
    (null, 'Todas'),
    (EstadoIncidencia.pendiente, 'Pendiente'),
    (EstadoIncidencia.asignada, 'Asignada'),
    (EstadoIncidencia.enProceso, 'En proceso'),
    (EstadoIncidencia.resuelta, 'Resuelta'),
    (EstadoIncidencia.reabierta, 'Reabierta'),
    (EstadoIncidencia.cerrada, 'Cerrada'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BarraPrincipal(
        accion: BotonCircular(
          key: const Key('abrir_perfil'),
          icono: Icons.person_outline,
          etiqueta: 'Perfil',
          onPressed: () => context.push(Rutas.perfil),
        ),
      ),
      body: Consumer<MisReportesViewModel>(
        builder: (context, vm, _) => ListaIncidencias(
          onRecargar: vm.cargar,
          onFinal: vm.cargarMas,
          encabezado: [
            // C4 va sin saludo ni chips
            if (!vm.sinReportes) Saludo(nombre: vm.nombre, subtitulo: 'Mis reportes'),
            if (vm.mostrarFiltros) ...[
              const SizedBox(height: 8),
              ChipsFiltro<EstadoIncidencia?>(
                opciones: _filtros,
                seleccionada: vm.filtro,
                onSeleccionar: vm.cambiarFiltro,
              ),
            ],
            const SizedBox(height: 16),
          ],
          contenido: _contenido(context, vm),
        ),
      ),
    );
  }

  List<Widget> _contenido(BuildContext context, MisReportesViewModel vm) => switch (vm.estado) {
    Cargando() => const [Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: EsqueletoTarjetas())],
    ConError(:final mensaje) => [EstadoVacio.error(mensaje: mensaje, onReintentar: vm.cargar)],
    Listo() => _lista(context, vm),
  };

  List<Widget> _lista(BuildContext context, MisReportesViewModel vm) {
    if (vm.sinReportes) {
      return [
        EstadoVacio(
          key: const Key('mis_reportes_vacio'),
          icono: Icons.assignment_turned_in,
          titulo: 'Sin reportes registrados',
          mensaje: 'Aquí podrás dar seguimiento detallado al avance y resolución de tus reportes ciudadanos.',
          accion: 'Hacer un reporte',
          onAccion: () => context.push(Rutas.nuevoReporte),
        ),
      ];
    }
    if (vm.reportes.isEmpty) {
      return const [
        EstadoVacio(
          icono: Icons.inbox_outlined,
          titulo: 'Sin reportes en este estado',
          mensaje: 'Elige otro filtro para ver tus demás reportes.',
        ),
      ];
    }
    return [
      ...conSeparacion(
        vm.reportes.map(
          (r) => IncidenciaCard(incidencia: r, meta: '${r.folio} · ${formatearFechaCorta(r.ultimaActualizacion)}'),
        ),
      ),
      if (vm.cargandoMas)
        const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
    ];
  }
}
