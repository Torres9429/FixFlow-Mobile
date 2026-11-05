// Test tipo Unitarias: se prueba una clase o función sin pantalla y sin red real

import 'package:fix_flow/data/models/incidencia_resumen_model.dart';
import 'package:fix_flow/domain/entities/estado_incidencia.dart';
import 'package:fix_flow/domain/entities/prioridad.dart';
import 'package:fix_flow/presentation/core/formato_fecha.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Resumen de incidencia: lectura del JSON del back', () {
    // `result` tal como lo manda GET /incidencias/mias
    final result = {
      'content': [
        {
          'id': 142,
          'folio': 'FX-2026-000142',
          'tipo': 'Bache',
          'tipoCodigo': 'BACHE',
          'estado': 'EN_PROCESO',
          'prioridad': 'ALTA',
          'motivoPrioridad': 'Sin resolver por más de 7 días',
          'latitud': 18.92,
          'longitud': -99.23,
          'operativo': 'Luis Ramírez',
          'fechaCreacion': '2026-10-28T15:15:00.000Z',
          'ultimaActualizacion': '2026-10-29T20:00:00.000Z',
          'fotoUrl': 'https://res.cloudinary.com/demo/bache.jpg',
        },
      ],
      'page': {'size': 20, 'number': 0, 'totalElements': 1, 'totalPages': 1},
    };

    test('Convierte estado y prioridad del back a los enums', () {
      final pagina = IncidenciaResumenModel.paginaFromJson(result);
      final incidencia = pagina.contenido.single;

      expect(incidencia.folio, 'FX-2026-000142');
      expect(incidencia.estado, EstadoIncidencia.enProceso);
      expect(incidencia.prioridad, Prioridad.alta);
      expect(incidencia.operativo, 'Luis Ramírez');
      expect(pagina.esUltima, isTrue);
    });

    test('Una incidencia Pendiente llega sin operativo ni foto', () {
      final json = Map<String, dynamic>.from((result['content'] as List).first as Map)
        ..['estado'] = 'PENDIENTE'
        ..['operativo'] = null
        ..['fotoUrl'] = null;

      final incidencia = IncidenciaResumenModel.fromJson(json);

      expect(incidencia.estado, EstadoIncidencia.pendiente);
      expect(incidencia.operativo, isNull);
      expect(incidencia.fotoUrl, isNull);
    });
  });

  group('Formato de fecha de las tarjetas (design.md §8)', () {
    final ahora = DateTime(2026, 11, 4, 18, 0);

    test('Mismo día → «hoy, HH:mm»', () {
      expect(formatearFechaCorta(DateTime(2026, 11, 4, 9, 5), ahora: ahora), 'hoy, 09:05');
    });

    test('Día anterior → «ayer, HH:mm»', () {
      expect(formatearFechaCorta(DateTime(2026, 11, 3, 18, 5), ahora: ahora), 'ayer, 18:05');
    });

    test('Más antigua → «28 oct 2026, 09:15»', () {
      expect(formatearFechaCorta(DateTime(2026, 10, 28, 9, 15), ahora: ahora), '28 oct 2026, 09:15');
    });
  });
}
