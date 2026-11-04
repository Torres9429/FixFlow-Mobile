import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../core/theme/app_colors.dart';

class MedirOrientacionScreen extends StatefulWidget {
  const MedirOrientacionScreen({super.key});

  @override
  State<MedirOrientacionScreen> createState() => _MedirOrientacionScreenState();
}

class _MedirOrientacionScreenState extends State<MedirOrientacionScreen> {
  StreamSubscription<AccelerometerEvent>? _suscripcion;
  Timer? _timer;
  AccelerometerEvent? _lectura;
  final Map<String, double> _mediciones = {};
  double _sumaX = 0;
  double _sumaY = 0;
  double _sumaZ = 0;
  int _muestras = 0;
  String? _midiendo;
  String? _error;
  bool _sensorIniciado = false;

  @override
  void initState() {
    super.initState();
  }

  void _iniciarSensor() {
    if (_sensorIniciado) return;
    _sensorIniciado = true;
    try {
      final stream = accelerometerEventStream(
        samplingPeriod: SensorInterval.normalInterval,
      );
      _suscripcion = stream.listen(
        (lectura) {
          if (!mounted) return;
          setState(() {
            _lectura = lectura;
            if (_midiendo != null) {
              _sumaX += lectura.x;
              _sumaY += lectura.y;
              _sumaZ += lectura.z;
              _muestras++;
            }
          });
        },
        onError: (Object error) {
          if (mounted) {
            setState(() => _error = 'No se pudo leer el acelerómetro: $error');
          }
        },
        cancelOnError: false,
      );
    } catch (error) {
      _error = 'No se pudo iniciar el acelerómetro: $error';
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _suscripcion?.cancel();
    super.dispose();
  }

  void _iniciarMedicion(String posicion) {
    _iniciarSensor();
    _timer?.cancel();
    setState(() {
      _midiendo = posicion;
      _sumaX = 0;
      _sumaY = 0;
      _sumaZ = 0;
      _muestras = 0;
      _error = null;
    });
    _timer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted || _muestras == 0) {
        if (mounted) {
          setState(() {
            _midiendo = null;
            _error = 'No se recibieron lecturas. Revisa que el dispositivo tenga acelerómetro.';
          });
        }
        return;
      }
      final x = _sumaX / _muestras;
      final y = _sumaY / _muestras;
      final z = _sumaZ / _muestras;
      setState(() {
        _mediciones[posicion] = _calcularAngulo(x, y, z);
        _midiendo = null;
      });
    });
  }

  double _calcularAngulo(double x, double y, double z) {
    return math.atan2(z, math.sqrt(x * x + y * y)) * 180 / math.pi;
  }

  double? get _anguloActual {
    final lectura = _lectura;
    if (lectura == null) return null;
    return _calcularAngulo(lectura.x, lectura.y, lectura.z);
  }

  String _formatear(double? valor) => valor == null ? '--' : '${valor.toStringAsFixed(1)}°';

  @override
  Widget build(BuildContext context) {
    final lectura = _lectura;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orientación'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(_mediciones),
            child: const Text('Listo'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        children: [
          const Text(
            'Coloca el teléfono en la posición que quieras comprobar y pulsa Medir.',
          ),
          const SizedBox(height: 16),
          Text(
            'Medición del acelerómetro',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Coloca la cámara trasera en cada posición y mantén el teléfono quieto. '
            'La medición promedia las lecturas durante 0.5 segundos.',
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Lectura actual', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Text('X: ${lectura?.x.toStringAsFixed(2) ?? '--'} m/s²'),
                  Text('Y: ${lectura?.y.toStringAsFixed(2) ?? '--'} m/s²'),
                  Text('Z: ${lectura?.z.toStringAsFixed(2) ?? '--'} m/s²'),
                  const SizedBox(height: 8),
                  Text('Ángulo: ${_formatear(_anguloActual)}', style: Theme.of(context).textTheme.titleLarge),
                  if (_midiendo != null) ...[
                    const SizedBox(height: 12),
                    LinearProgressIndicator(),
                    const SizedBox(height: 6),
                    Text('Midiendo $_midiendo…'),
                  ],
                ],
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppColors.error)),
          ],
          const SizedBox(height: 20),
          _MedicionRow(
            titulo: 'Cámara hacia el suelo',
            referencia: 'RN-11: ≥ +45°',
            valor: _mediciones['suelo'],
            activo: _midiendo == 'suelo',
            onPressed: () => _iniciarMedicion('suelo'),
          ),
          _MedicionRow(
            titulo: 'Cámara hacia el frente',
            referencia: 'Referencia: cerca de 0°',
            valor: _mediciones['frente'],
            activo: _midiendo == 'frente',
            onPressed: () => _iniciarMedicion('frente'),
          ),
          _MedicionRow(
            titulo: 'Cámara hacia arriba',
            referencia: 'RN-11: ≤ −20°',
            valor: _mediciones['arriba'],
            activo: _midiendo == 'arriba',
            onPressed: () => _iniciarMedicion('arriba'),
          ),
          const SizedBox(height: 16),
          const Text(
            'La fórmula supone el teléfono en orientación vertical y usa el eje Z '
            'para representar la inclinación de la cámara trasera. Conserva también '
            'los valores X, Y y Z para comparar modelos.',
          ),
        ],
      ),
    );
  }
}

class _MedicionRow extends StatelessWidget {
  const _MedicionRow({
    required this.titulo,
    required this.referencia,
    required this.valor,
    required this.activo,
    required this.onPressed,
  });

  final String titulo;
  final String referencia;
  final double? valor;
  final bool activo;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(titulo),
        subtitle: Text('$referencia\nResultado: ${valor == null ? 'pendiente' : '${valor!.toStringAsFixed(1)}°'}'),
        isThreeLine: true,
        trailing: FilledButton(
          onPressed: activo ? null : onPressed,
          child: Text(activo ? 'Midiendo' : 'Medir'),
        ),
      ),
    );
  }
}
