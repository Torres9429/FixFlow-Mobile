import 'package:flutter/material.dart';

import '../../../../domain/entities/tipo_incidencia.dart';
import '../../../core/theme/app_colors.dart';

/// Barra de inclinación que ilustra el rango del horizonte (Cielo -90° a Suelo +90°)
/// y resalta en verde [AppColors.guiaValida] la zona requerida por el tipo de incidencia (RN-11 / #23).
class BarraInclinacion extends StatelessWidget {
  const BarraInclinacion({
    super.key,
    required this.angulo,
    required this.orientacion,
    required this.enRango,
  });

  final double? angulo;
  final OrientacionFoto orientacion;
  final bool enRango;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 20,
          child: CustomPaint(
            painter: _BarraInclinacionPainter(
              angulo: angulo,
              orientacion: orientacion,
              enRango: enRango,
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Cielo',
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Horizonte',
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Suelo',
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BarraInclinacionPainter extends CustomPainter {
  const _BarraInclinacionPainter({
    required this.angulo,
    required this.orientacion,
    required this.enRango,
  });

  final double? angulo;
  final OrientacionFoto orientacion;
  final bool enRango;

  double _anguloAFaccion(double deg) {
    return ((deg.clamp(-90.0, 90.0) + 90.0) / 180.0).clamp(0.0, 1.0);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    const trackHeight = 6.0;

    // 1. Pista base (gris oscuro)
    final trackRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, centerY - (trackHeight / 2), size.width, trackHeight),
      const Radius.circular(3),
    );
    final trackPaint = Paint()
      ..color = const Color(0xFF374151)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(trackRect, trackPaint);

    // 2. Zona Verde según el tipo de incidencia (RN-11)
    final greenZonePaint = Paint()
      ..color = AppColors.guiaValida
      ..style = PaintingStyle.fill;

    if (orientacion == OrientacionFoto.suelo) {
      // Suelo: de 45° a 90° (75% a 100% de la pista)
      final startX = size.width * _anguloAFaccion(45.0);
      final greenRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(startX, centerY - (trackHeight / 2), size.width - startX, trackHeight),
        const Radius.circular(3),
      );
      canvas.drawRRect(greenRect, greenZonePaint);
    } else if (orientacion == OrientacionFoto.arriba) {
      // Arriba: de -90° a -20° (0% a ~38.9% de la pista)
      final endX = size.width * _anguloAFaccion(-20.0);
      final greenRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, centerY - (trackHeight / 2), endX, trackHeight),
        const Radius.circular(3),
      );
      canvas.drawRRect(greenRect, greenZonePaint);
    } else {
      // Sin restricción: toda la barra es verde
      canvas.drawRRect(trackRect, greenZonePaint);
    }

    // 3. Marca del centro (Horizonte 0°)
    final horizonX = size.width * _anguloAFaccion(0.0);
    final tickPaint = Paint()
      ..color = const Color(0xFF9CA3AF)
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(horizonX, centerY - 6),
      Offset(horizonX, centerY + 6),
      tickPaint,
    );

    // 4. Cursor / Punto indicador de la lectura actual
    final currentAngle = angulo ?? 0.0;
    final thumbX = size.width * _anguloAFaccion(currentAngle);
    final thumbColor = enRango ? AppColors.guiaValida : AppColors.guiaInvalida;

    // Sombra del cursor
    canvas.drawCircle(
      Offset(thumbX, centerY),
      8,
      Paint()
        ..color = Colors.black38
        ..style = PaintingStyle.fill,
    );

    // Círculo principal del cursor
    canvas.drawCircle(
      Offset(thumbX, centerY),
      7,
      Paint()
        ..color = thumbColor
        ..style = PaintingStyle.fill,
    );

    // Punto central blanco
    canvas.drawCircle(
      Offset(thumbX, centerY),
      3,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_BarraInclinacionPainter oldDelegate) {
    return oldDelegate.angulo != angulo ||
        oldDelegate.orientacion != orientacion ||
        oldDelegate.enRango != enRango;
  }
}

