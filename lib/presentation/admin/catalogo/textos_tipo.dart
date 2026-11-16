import '../../../domain/entities/prioridad.dart';
import '../../../domain/entities/tipo_incidencia.dart';

/// Cómo se lee cada opción en E10, E11 y E12 (PRD §3).
String textoOrientacion(OrientacionFoto o) => switch (o) {
  OrientacionFoto.suelo => 'Hacia el suelo',
  OrientacionFoto.arriba => 'Hacia arriba',
  OrientacionFoto.sinRestriccion => 'Sin restricción',
};

/// «Hacia el suelo (45° a 90°)» con los ángulos que manda el servidor; sin restricción, «(libre)».
String textoOrientacionConRango(TipoIncidencia tipo) {
  final base = textoOrientacion(tipo.orientacion);
  if (tipo.orientacion == OrientacionFoto.sinRestriccion) return '$base (libre)';
  final (min, max) = (tipo.anguloMin, tipo.anguloMax);
  if (min == null || max == null) return base;
  return '$base (${_grados(min)} a ${_grados(max)})';
}

String _grados(double valor) => '${valor < 0 ? '−' : ''}${valor.abs().round()}°';

String textoPrioridad(Prioridad p) => switch (p) {
  Prioridad.alta => 'Alta',
  Prioridad.media => 'Media',
  Prioridad.baja => 'Baja',
};

String textoIncidencias(int n) => '$n ${n == 1 ? 'incidencia' : 'incidencias'}';
