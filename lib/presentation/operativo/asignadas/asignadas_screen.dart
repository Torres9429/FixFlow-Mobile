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
import 'asignadas_viewmodel.dart';

/// D1 Mis asignadas.
class AsignadasScreen extends StatelessWidget {
  const AsignadasScreen({super.key});

  // El operativo solo tiene incidencias activas (RN-14)
  static const _filtros = <(EstadoIncidencia?, String)>[
    (null, 'Todas'),
    (EstadoIncidencia.asignada, 'Asignada'),
    (EstadoIncidencia.enProceso, 'En proceso'),
    (EstadoIncidencia.reabierta, 'Reabierta'),
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
      body: Consumer<AsignadasViewModel>(
        builder: (context, vm, _) => ListaIncidencias(
          onRecargar: vm.cargar,
          onFinal: vm.cargarMas,
          encabezado: [
            Saludo(nombre: vm.nombre, subtitulo: vm.resumen),
            const SizedBox(height: 8),
            ChipsFiltro<EstadoIncidencia?>(
              opciones: _filtros,
              seleccionada: vm.filtro,
              onSeleccionar: vm.cambiarFiltro,
            ),
            const SizedBox(height: 16),
          ],
          contenido: _contenido(context, vm),
        ),
      ),
    );
  }

  List<Widget> _contenido(BuildContext context, AsignadasViewModel vm) => switch (vm.estado) {
    Cargando() => const [Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: EsqueletoTarjetas())],
    ConError(:final mensaje) => [EstadoVacio.error(mensaje: mensaje, onReintentar: vm.cargar)],
    Listo() => _lista(context, vm),
  };

  List<Widget> _lista(BuildContext context, AsignadasViewModel vm) {
    if (vm.asignadas.isEmpty) {
      return [
        EstadoVacio(
          icono: Icons.inbox_outlined,
          titulo: vm.filtro == null ? 'No tienes incidencias asignadas' : 'Sin incidencias en este estado',
          mensaje: vm.filtro == null
              ? 'Cuando el administrador te asigne una, aparecerá aquí.'
              : 'Elige otro filtro para ver tus demás incidencias.',
        ),
      ];
    }
    return [
      ...conSeparacion(
        vm.asignadas.map((i) {
          final distancia = vm.distancia(i);
          return IncidenciaCard(
            incidencia: i,
            meta: [i.folio, formatearFechaCorta(i.ultimaActualizacion), ?distancia].join(' · '),
            onTap: () => context.push(Rutas.detalleOperativo(i.id)),
          );
        }),
      ),
      if (vm.cargandoMas)
        const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
    ];
  }
}
