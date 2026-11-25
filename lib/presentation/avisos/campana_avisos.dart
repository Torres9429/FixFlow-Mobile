import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/widgets/barra_principal.dart';
import '../routing/rutas.dart';
import 'contador_avisos_viewmodel.dart';

/// Campana del admin en E1, E2 y E8: abre E7 y lleva el punto naranja si hay avisos sin leer.
class CampanaAvisos extends StatelessWidget {
  const CampanaAvisos({super.key});

  @override
  Widget build(BuildContext context) {
    // Opcional: las pruebas de cada pantalla la dibujan sin el shell
    final contador = context.watch<ContadorAvisosViewModel?>();
    return BotonCircular(
      key: const Key('abrir_avisos'),
      icono: Icons.notifications_outlined,
      etiqueta: 'Avisos',
      conPunto: contador?.hayNoLeidos ?? false,
      onPressed: () async {
        await context.push(Rutas.avisosAdmin);
        // E7 vive fuera del shell: al volver se actualiza el punto
        await contador?.cargar();
      },
    );
  }
}
