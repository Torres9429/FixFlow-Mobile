import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/result.dart';
import '../../domain/entities/aviso.dart';
import '../../domain/entities/rol.dart';
import '../core/estado_consulta.dart';
import '../core/formato_fecha.dart';
import '../core/mensajes.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/esqueleto_tarjetas.dart';
import '../core/widgets/estado_vacio.dart';
import '../core/widgets/lista_incidencias.dart';
import 'avisos_viewmodel.dart';
import 'contador_avisos_viewmodel.dart';
import 'ruta_aviso.dart';

/// C1 (ciudadano, pestaña), D6 (operativo, pestaña) y E7 (admin, desde la campana).
class AvisosScreen extends StatelessWidget {
  const AvisosScreen({super.key, required this.rol});

  final Rol rol;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AvisosViewModel>();
    // C1 y D6 viven en el shell: si el contador sube (push o volver a la app), la lista se recarga
    final contador = context.watch<ContadorAvisosViewModel?>();
    WidgetsBinding.instance.addPostFrameCallback((_) => vm.sincronizar(contador?.noLeidos));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Avisos'),
        actions: [
          TextButton(
            key: const Key('marcar_todo_leido'),
            onPressed: vm.hayNoLeidos && !vm.marcandoTodos ? () => _marcarTodos(context, vm, contador) : null,
            child: const Text('Marcar todo como leído'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListaIncidencias(
        onRecargar: vm.cargar,
        onFinal: vm.cargarMas,
        encabezado: const [],
        contenido: switch (vm.estado) {
          Cargando() => const [Padding(padding: EdgeInsets.all(20), child: EsqueletoTarjetas())],
          ConError(:final mensaje) => [EstadoVacio.error(mensaje: mensaje, onReintentar: vm.cargar)],
          Listo() => _lista(context, vm, contador),
        },
      ),
    );
  }

  List<Widget> _lista(BuildContext context, AvisosViewModel vm, ContadorAvisosViewModel? contador) {
    if (vm.avisos.isEmpty) {
      return [
        EstadoVacio(
          icono: Icons.notifications_none_outlined,
          titulo: 'No tienes avisos',
          mensaje: switch (rol) {
            Rol.ciudadano => 'Aquí te avisaremos cuando tus reportes cambien de estado.',
            Rol.operativo => 'Aquí verás las incidencias que te asignen o que se reabran.',
            _ => 'Aquí verás las incidencias que los ciudadanos reabran.',
          },
        ),
      ];
    }
    return [
      for (final (titulo, avisos) in vm.grupos) ...[
        _TituloGrupo(titulo),
        for (final (i, aviso) in avisos.indexed) ...[
          if (i > 0) const Divider(height: 1, thickness: 1, indent: 20, endIndent: 20, color: AppColors.borderSubtle),
          _FilaAviso(aviso: aviso, onTap: () => _abrir(context, vm, contador, aviso)),
        ],
      ],
      if (vm.cargandoMas) const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
    ];
  }

  Future<void> _abrir(BuildContext context, AvisosViewModel vm, ContadorAvisosViewModel? contador, Aviso aviso) async {
    // Se marca sin esperar: abrir la incidencia no debe tardar por esto
    vm.marcarLeido(aviso).then((_) => contador?.cargar());
    context.go(rutaDeAviso(rol, aviso.incidenciaId, aviso.accion));
  }

  Future<void> _marcarTodos(BuildContext context, AvisosViewModel vm, ContadorAvisosViewModel? contador) async {
    final res = await vm.marcarTodos();
    await contador?.cargar();
    if (res case Error(error: final falla) when context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensajePara(falla))));
    }
  }
}

class _TituloGrupo extends StatelessWidget {
  const _TituloGrupo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Text(
        texto,
        style: Theme.of(context).textTheme.labelLarge
            ?.copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted),
      ),
    );
  }
}

/// Fila sin tarjeta (design.md, Avisos): punto naranja y título en 700 si no se ha leído.
class _FilaAviso extends StatelessWidget {
  const _FilaAviso({required this.aviso, required this.onTap});

  final Aviso aviso;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return InkWell(
      key: Key('aviso_${aviso.id}'),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 7, right: 12),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: aviso.leida ? Colors.transparent : AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    aviso.titulo,
                    style: texto.titleSmall?.copyWith(
                      fontSize: 15,
                      height: 22 / 15,
                      fontWeight: aviso.leida ? FontWeight.w500 : FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    aviso.mensaje,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: texto.bodyMedium?.copyWith(fontSize: 14, height: 20 / 14, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    haceCuanto(aviso.fecha),
                    style: texto.bodySmall?.copyWith(fontSize: 13, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
