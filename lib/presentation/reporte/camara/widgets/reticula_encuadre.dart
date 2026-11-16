import 'package:flutter/material.dart';

import '../../../../domain/entities/tipo_incidencia.dart';
import '../../../core/theme/app_colors.dart';

/// Retícula de encuadre en el centro de la cámara (B3 / #23).
///
/// Cambia visualmente según el estado del sensor:
/// - En ángulo válido: marco verde sólido [AppColors.guiaValida].
/// - Fuera de ángulo: marco ámbar punteado con flecha indicadora de dirección.
class ReticulaEncuadre extends StatelessWidget {
  const ReticulaEncuadre({
    super.key,
    required this.enRango,
    required this.orientacion,
  });

  final bool enRango;
  final OrientacionFoto orientacion;

  @override
  Widget build(BuildContext context) {
    const double size = 260;
    final color = enRango ? AppColors.guiaValida : AppColors.guiaInvalida;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(size, size),
            painter: _ReticulaPainter(
              color: color,
              enRango: enRango,
              radius: 16,
              strokeWidth: 2.5,
            ),
          ),
          if (!enRango && orientacion != OrientacionFoto.sinRestriccion)
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0x66000000),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: Icon(
                orientacion == OrientacionFoto.suelo
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
        ],
      ),
    );
  }
}

class _ReticulaPainter extends CustomPainter {
  const _ReticulaPainter({
    required this.color,
    required this.enRango,
    required this.radius,
    required this.strokeWidth,
  });

  final Color color;
  final bool enRango;
  final double radius;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    if (enRango) {
      canvas.drawRRect(rrect, paint);
      return;
    }

    // Dibujado de borde punteado / discontinuo si está fuera de rango
    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      const double dashLength = 10;
      const double dashSpace = 6;
      double distance = 0;
      while (distance < metric.length) {
        final double end = (distance + dashLength).clamp(0, metric.length);
        final extractPath = metric.extractPath(distance, end);
        canvas.drawPath(extractPath, paint);
        distance += dashLength + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(_ReticulaPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.enRango != enRango ||
        oldDelegate.radius != radius ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

