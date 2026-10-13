import 'package:flutter/widgets.dart';

import 'home_base.dart';

class HomeAdminScreen extends StatelessWidget {
  const HomeAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeBase(
      titulo: 'Inicio · Administrador',
      descripcion: 'Aquí irán las incidencias municipales (HU-17).',
    );
  }
}
