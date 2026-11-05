import '../entities/reporte_nuevo.dart';
import '../entities/tipo_incidencia.dart';

// Umbrales de RN-11 (design.md §2). El back valida con los suyos; esto solo evita un envío que va a fallar.
const _sueloMin = 45.0;
const _arribaMax = -20.0;

/// RN-12: la evidencia tiene foto, ubicación e inclinación válida para el tipo.
/// Devuelve el motivo para mostrar, o `null` si se puede enviar.
String? validarEvidencia(ReporteNuevo r) {
  if (r.rutaFoto.isEmpty) return 'Falta la foto. Vuelve a capturarla.';
  if (r.latitud.abs() > 90 || r.longitud.abs() > 180) return 'No se obtuvo la ubicación. Vuelve a capturar la foto.';

  final inclinacion = r.inclinacion;
  if (inclinacion == null) return 'No se pudo medir la inclinación del teléfono. Vuelve a capturar la foto.';

  return switch (r.tipo.orientacion) {
    OrientacionFoto.suelo when inclinacion < _sueloMin =>
      'Para este tipo la foto se toma apuntando hacia el suelo. Vuelve a capturarla.',
    OrientacionFoto.arriba when inclinacion > _arribaMax =>
      'Para este tipo la foto se toma apuntando hacia arriba. Vuelve a capturarla.',
    _ => null,
  };
}
