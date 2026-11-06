import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../domain/repositories/direccion_repository.dart';
import '../../domain/repositories/incidencias_repository.dart';
import 'detalle_incidencia_screen.dart';
import 'detalle_incidencia_viewmodel.dart';
import 'vista_detalle.dart';

/// Subruta `:id` del detalle. Cada rol la cuelga de su home en su propio archivo de rutas,
/// así el detalle se abre dentro de la pestaña y conserva la barra inferior.
GoRoute rutaDetalle(VistaDetalle vista) => GoRoute(
  path: ':id',
  builder: (context, state) => ChangeNotifierProvider(
    create: (context) => DetalleIncidenciaViewModel(
      // Un id que no es número termina en «No encontramos lo que buscabas» (404 del back)
      id: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
      vista: vista,
      incidenciasRepository: context.read<IncidenciasRepository>(),
      direccionRepository: context.read<DireccionRepository>(),
    )..iniciar(),
    child: const DetalleIncidenciaScreen(),
  ),
);
