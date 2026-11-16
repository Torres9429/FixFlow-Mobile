import 'prioridad.dart';

/// Hacia dónde debe apuntar el teléfono al tomar la foto (RN-11).
enum OrientacionFoto { suelo, arriba, sinRestriccion }

class TipoIncidencia {
  const TipoIncidencia({
    required this.id,
    required this.nombre,
    this.codigo = '',
    this.orientacion = OrientacionFoto.sinRestriccion,
    this.prioridadBase = Prioridad.media,
    this.activo = true,
    this.incidencias,
    this.anguloMin,
    this.anguloMax,
  });

  final String id;
  final String nombre;

  /// Código fijo del catálogo, por ejemplo `BACHE` (RN-07).
  final String codigo;
  final OrientacionFoto orientacion;

  /// Prioridad con la que nace un reporte de este tipo (RN-13).
  final Prioridad prioridadBase;

  /// Un tipo inactivo no aparece al crear un reporte (HU-26).
  final bool activo;

  /// Cuántas incidencias usan el tipo. Solo llega en el catálogo del admin (E10, E12).
  final int? incidencias;

  /// Zona válida de inclinación en grados, calculada por el servidor (RN-11). La app no la tiene escrita.
  final double? anguloMin;
  final double? anguloMax;

  TipoIncidencia copyWith({
    String? nombre,
    OrientacionFoto? orientacion,
    Prioridad? prioridadBase,
    bool? activo,
    double? anguloMin,
    double? anguloMax,
  }) => TipoIncidencia(
    id: id,
    nombre: nombre ?? this.nombre,
    codigo: codigo,
    orientacion: orientacion ?? this.orientacion,
    prioridadBase: prioridadBase ?? this.prioridadBase,
    activo: activo ?? this.activo,
    incidencias: incidencias,
    anguloMin: anguloMin ?? this.anguloMin,
    anguloMax: anguloMax ?? this.anguloMax,
  );
}

/// Lo que se manda al crear o editar un tipo (E11, E12). Al editar, [codigo] se ignora.
class DatosTipo {
  const DatosTipo({
    this.codigo,
    required this.nombre,
    required this.orientacion,
    required this.prioridadBase,
  });

  /// Vacío o `null` al crear: el servidor lo genera del nombre.
  final String? codigo;
  final String nombre;
  final OrientacionFoto orientacion;
  final Prioridad prioridadBase;
}

/// El código que el servidor generaría para [nombre]: sin acentos, en mayúsculas y con `_` (HU-26).
/// Solo se usa para la ayuda de E11; el código real lo decide el servidor.
String codigoSugerido(String nombre) {
  const acentos = {'Á': 'A', 'É': 'E', 'Í': 'I', 'Ó': 'O', 'Ú': 'U', 'Ü': 'U', 'Ñ': 'N'};
  final mayusculas = nombre.trim().toUpperCase().split('').map((c) => acentos[c] ?? c).join();
  final codigo = mayusculas
      .replaceAll(RegExp(r'[^A-Z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
  return codigo.length > 30 ? codigo.substring(0, 30).replaceAll(RegExp(r'_+$'), '') : codigo;
}
