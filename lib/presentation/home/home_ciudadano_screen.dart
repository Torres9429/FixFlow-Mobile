import 'package:flutter/widgets.dart';

import 'home_base.dart';

class HomeCiudadanoScreen extends StatelessWidget {
  const HomeCiudadanoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeBase(
      titulo: 'Inicio · Ciudadano',
      descripcion: 'Aquí irán tus reportes (HU-10).',
    );
  }
}
