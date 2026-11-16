import 'package:flutter/material.dart';

import '../../../domain/entities/tipo_incidencia.dart';
import '../../core/widgets/hoja_confirmacion.dart';

/// E12a y su contraparte para reactivar, en la misma hoja inferior que el resto de la app.
/// Devuelve `true` si el admin confirma.
Future<bool> confirmarEstatusTipo(BuildContext context, TipoIncidencia tipo) {
  final activar = !tipo.activo;
  return confirmarAccion(
    context,
    titulo: activar ? '¿Activar ${tipo.nombre}?' : '¿Desactivar ${tipo.nombre}?',
    mensaje: activar
        ? 'Volverá a aparecer al crear un reporte.'
        : 'Ya no aparecerá en reportes nuevos; las incidencias existentes lo conservan.',
    accion: activar ? 'Activar tipo' : 'Desactivar tipo',
    destructiva: !activar,
    claveConfirmar: const Key('confirmar_estatus_tipo'),
    detalle: DatosHoja(
      datos: [('Código', tipo.codigo), ('Incidencias que lo usan', '${tipo.incidencias ?? 0}')],
    ),
  );
}

/// Texto del snackbar después de cambiar el estatus.
String avisoEstatusTipo(TipoIncidencia tipo) =>
    tipo.activo ? '${tipo.nombre} desactivado.' : '${tipo.nombre} activado.';
