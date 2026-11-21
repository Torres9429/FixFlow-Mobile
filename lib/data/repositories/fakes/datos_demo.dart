import '../../../domain/entities/estado_incidencia.dart';
import '../../../domain/entities/incidencia_resumen.dart';
import '../../../domain/entities/prioridad.dart';
import '../../../domain/entities/tipo_incidencia.dart';

/// Datos de ejemplo de design.md §9, iguales en todas las pantallas del modo mock.
abstract final class DatosDemo {
  static final _ahora = DateTime.now();

  /// Los umbrales de RN-11 que manda el servidor: suelo ≥ +45°, arriba ≤ −20°.
  static (double, double) angulos(OrientacionFoto o) => switch (o) {
    OrientacionFoto.suelo => (45, 90),
    OrientacionFoto.arriba => (-90, -20),
    OrientacionFoto.sinRestriccion => (-90, 90),
  };

  static TipoIncidencia tipo(
    String id,
    String nombre,
    String codigo,
    OrientacionFoto orientacion,
    Prioridad prioridad,
    int incidencias, {
    bool activo = true,
  }) {
    final (min, max) = angulos(orientacion);
    return TipoIncidencia(
      id: id,
      nombre: nombre,
      codigo: codigo,
      orientacion: orientacion,
      prioridadBase: prioridad,
      activo: activo,
      incidencias: incidencias,
      anguloMin: min,
      anguloMax: max,
    );
  }

  /// Los 9 tipos de RN-07 con su orientación y prioridad base, más Grafiti inactivo (design.md, E10).
  /// Una sola lista para el catálogo (E10), B2 y el filtro por tipo de E2.
  static final tipos = <TipoIncidencia>[
    tipo('1', 'Bache', 'BACHE', OrientacionFoto.suelo, Prioridad.media, 142),
    tipo('2', 'Luminaria apagada o dañada', 'LUMINARIA', OrientacionFoto.arriba, Prioridad.media, 87),
    tipo('3', 'Fuga de agua', 'FUGA_AGUA', OrientacionFoto.sinRestriccion, Prioridad.alta, 64),
    tipo('4', 'Coladera sin tapa u obstruida', 'COLADERA', OrientacionFoto.suelo, Prioridad.alta, 31),
    tipo('5', 'Árbol o rama caída', 'ARBOL_CAIDO', OrientacionFoto.sinRestriccion, Prioridad.alta, 22),
    tipo('6', 'Señalamiento vial dañado', 'SENALAMIENTO', OrientacionFoto.sinRestriccion, Prioridad.media, 18),
    tipo('7', 'Banqueta dañada', 'BANQUETA', OrientacionFoto.suelo, Prioridad.baja, 40),
    tipo('8', 'Basura acumulada', 'BASURA', OrientacionFoto.sinRestriccion, Prioridad.baja, 55),
    tipo('9', 'Otro', 'OTRO', OrientacionFoto.sinRestriccion, Prioridad.baja, 12),
    tipo('10', 'Grafiti', 'GRAFITI', OrientacionFoto.sinRestriccion, Prioridad.baja, 3, activo: false),
  ];

  static IncidenciaResumen _incidencia({
    required int id,
    required String tipo,
    required String codigo,
    required EstadoIncidencia estado,
    required Prioridad prioridad,
    required String motivo,
    required double lat,
    required double lng,
    required Duration hace,
    String? operativo,
  }) => IncidenciaResumen(
    id: id,
    folio: 'FX-2026-${id.toString().padLeft(6, '0')}',
    tipo: tipo,
    tipoCodigo: codigo,
    estado: estado,
    prioridad: prioridad,
    motivoPrioridad: motivo,
    latitud: lat,
    longitud: lng,
    operativo: operativo,
    fechaCreacion: _ahora.subtract(hace + const Duration(days: 2)),
    ultimaActualizacion: _ahora.subtract(hace),
  );

  static final fuga097Resuelta = _incidencia(
    id: 97,
    tipo: 'Fuga de agua',
    codigo: 'FUGA_AGUA',
    estado: EstadoIncidencia.resuelta,
    prioridad: Prioridad.alta,
    motivo: 'Tipo de incidencia: Fuga de agua',
    lat: 18.9242,
    lng: -99.2216,
    hace: const Duration(hours: 1),
    operativo: 'Luis Ramírez',
  );

  static final bache142 = _incidencia(
    id: 142,
    tipo: 'Bache',
    codigo: 'BACHE',
    estado: EstadoIncidencia.pendiente,
    prioridad: Prioridad.media,
    motivo: 'Tipo de incidencia: Bache',
    lat: 18.9186,
    lng: -99.2342,
    hace: const Duration(hours: 3),
  );

  static final bache123 = _incidencia(
    id: 123,
    tipo: 'Bache',
    codigo: 'BACHE',
    estado: EstadoIncidencia.enProceso,
    prioridad: Prioridad.media,
    motivo: 'Tipo de incidencia: Bache',
    lat: 18.9301,
    lng: -99.2279,
    hace: const Duration(days: 1),
    operativo: 'Luis Ramírez',
  );

  static final luminaria118 = _incidencia(
    id: 118,
    tipo: 'Luminaria apagada o dañada',
    codigo: 'LUMINARIA',
    estado: EstadoIncidencia.asignada,
    prioridad: Prioridad.media,
    motivo: 'Tipo de incidencia: Luminaria apagada o dañada',
    lat: 18.9357,
    lng: -99.2410,
    hace: const Duration(days: 8),
    operativo: 'Luis Ramírez',
  );

  static final bache131 = _incidencia(
    id: 131,
    tipo: 'Bache',
    codigo: 'BACHE',
    estado: EstadoIncidencia.asignada,
    prioridad: Prioridad.alta,
    motivo: 'Sin resolver por más de 7 días',
    lat: 18.9215,
    lng: -99.2305,
    hace: const Duration(hours: 2),
    operativo: 'Luis Ramírez',
  );

  static final bache140 = _incidencia(
    id: 140,
    tipo: 'Bache',
    codigo: 'BACHE',
    estado: EstadoIncidencia.pendiente,
    prioridad: Prioridad.alta,
    motivo: 'Sin resolver por más de 7 días',
    lat: 18.9268,
    lng: -99.2391,
    hace: const Duration(minutes: 45),
  );

  static final fuga137 = _incidencia(
    id: 137,
    tipo: 'Fuga de agua',
    codigo: 'FUGA_AGUA',
    estado: EstadoIncidencia.pendiente,
    prioridad: Prioridad.alta,
    motivo: 'Tipo de incidencia: Fuga de agua',
    lat: 18.9159,
    lng: -99.2250,
    hace: const Duration(hours: 5),
  );

  /// La misma fuga 000097, ya reabierta, como la ve el operativo.
  static final fuga097Reabierta = IncidenciaResumen(
    id: fuga097Resuelta.id,
    folio: fuga097Resuelta.folio,
    tipo: fuga097Resuelta.tipo,
    tipoCodigo: fuga097Resuelta.tipoCodigo,
    estado: EstadoIncidencia.reabierta,
    prioridad: Prioridad.alta,
    motivoPrioridad: 'Reabierta por el ciudadano',
    latitud: fuga097Resuelta.latitud,
    longitud: fuga097Resuelta.longitud,
    operativo: fuga097Resuelta.operativo,
    fechaCreacion: fuga097Resuelta.fechaCreacion,
    ultimaActualizacion: _ahora.subtract(const Duration(days: 1)),
  );

  /// Mis reportes de Ana: la Resuelta primero (design.md, B1).
  static List<IncidenciaResumen> get reportesAna => [fuga097Resuelta, bache142, bache123, luminaria118];

  /// Asignadas de Luis, prioridad alta primero (D1).
  static List<IncidenciaResumen> get asignadasLuis => [bache131, fuga097Reabierta, bache123, luminaria118];

  /// Todas las del municipio que conoce el modo mock (E1, E2).
  static List<IncidenciaResumen> get municipio => [
    bache140,
    fuga137,
    bache142,
    bache131,
    fuga097Reabierta,
    bache123,
    luminaria118,
  ];
}
