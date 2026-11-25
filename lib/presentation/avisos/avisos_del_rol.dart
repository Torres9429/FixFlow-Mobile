import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/rol.dart';
import '../../domain/repositories/avisos_repository.dart';
import '../../domain/repositories/push_repository.dart';
import 'contador_avisos_viewmodel.dart';
import 'push_viewmodel.dart';
import 'ruta_aviso.dart';

/// Envuelve el shell de un rol con lo que viven todas sus pestañas: el contador de no leídos
/// (punto naranja) y los push. [construirShell] recibe si hay avisos sin leer.
class AvisosDelRol extends StatelessWidget {
  const AvisosDelRol({super.key, required this.rol, required this.construirShell});

  final Rol rol;
  final Widget Function(bool hayNoLeidos) construirShell;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ContadorAvisosViewModel(avisosRepository: context.read<AvisosRepository>())..cargar(),
        ),
        ChangeNotifierProvider(
          create: (context) => PushViewModel(pushRepository: context.read<PushRepository>())..iniciar(),
        ),
      ],
      child: _EscuchaAvisos(
        rol: rol,
        child: Consumer<ContadorAvisosViewModel>(builder: (context, contador, _) => construirShell(contador.hayNoLeidos)),
      ),
    );
  }
}

/// Abre la incidencia del push tocado, muestra el que llega con la app abierta
/// y recarga el contador al volver a la app (no hay push en tiempo real para la bandeja).
class _EscuchaAvisos extends StatefulWidget {
  const _EscuchaAvisos({required this.rol, required this.child});

  final Rol rol;
  final Widget child;

  @override
  State<_EscuchaAvisos> createState() => _EscuchaAvisosState();
}

class _EscuchaAvisosState extends State<_EscuchaAvisos> {
  late final AppLifecycleListener _ciclo;

  @override
  void initState() {
    super.initState();
    _ciclo = AppLifecycleListener(onResume: () => context.read<ContadorAvisosViewModel>().cargar());
  }

  @override
  void dispose() {
    _ciclo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final push = context.watch<PushViewModel>();
    final porAbrir = push.tomarPorAbrir();
    final recibido = push.tomarRecibido();

    if (porAbrir != null || recibido != null) {
      // Navegar o mostrar el snackbar después de dibujar, nunca durante build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (porAbrir != null) context.go(rutaDeAviso(widget.rol, porAbrir.incidenciaId, porAbrir.accion));
        if (recibido != null) {
          context.read<ContadorAvisosViewModel>().cargar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(recibido.mensaje.isEmpty ? recibido.titulo : recibido.mensaje),
              action: SnackBarAction(
                label: 'Ver',
                onPressed: () => context.go(rutaDeAviso(widget.rol, recibido.incidenciaId, recibido.accion)),
              ),
            ),
          );
        }
      });
    }
    return widget.child;
  }
}
