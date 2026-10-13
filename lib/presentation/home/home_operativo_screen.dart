import 'package:flutter/widgets.dart';

import 'home_base.dart';

class HomeOperativoScreen extends StatelessWidget {
  const HomeOperativoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeBase(
      titulo: 'Inicio · Personal operativo',
      descripcion: 'Aquí irán tus incidencias asignadas (HU-14).',
    );
  }
}
