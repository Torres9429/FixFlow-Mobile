import '../entities/reporte_nuevo.dart';
import '../entities/tipo_incidencia.dart';

/// RN-12: la evidencia tiene foto, ubicación e inclinación válida para el tipo.
/// Devuelve el motivo para mostrar, o `null` si se puede enviar.
String? validarEvidencia(ReporteNuevo r) {
  if (r.rutaFoto.isEmpty) return 'Falta la foto. Vuelve a capturarla.';
  if (r.latitud.abs() > 90 || r.longitud.abs() > 180) return 'No se obtuvo la ubicación. Vuelve a capturar la foto.';

  // Sin acelerómetro no hay lectura que validar (RN-11, RN-12)
  if (r.sinSensor) return null;

  final inclinacion = r.inclinacion;
  if (inclinacion == null) return 'No se pudo medir la inclinación del teléfono. Vuelve a capturar la foto.';

  // Zona válida del tipo que manda el servidor (RN-11); sin ella, decide el servidor al enviar
  final (min, max) = (r.tipo.anguloMin, r.tipo.anguloMax);
  if (r.tipo.orientacion == OrientacionFoto.sinRestriccion || min == null || max == null) return null;
  if (inclinacion >= min && inclinacion <= max) return null;
  return switch (r.tipo.orientacion) {
    OrientacionFoto.suelo => 'Para este tipo la foto se toma apuntando hacia el suelo. Vuelve a capturarla.',
    OrientacionFoto.arriba => 'Para este tipo la foto se toma apuntando hacia arriba. Vuelve a capturarla.',
    OrientacionFoto.sinRestriccion => null,
  };
}
