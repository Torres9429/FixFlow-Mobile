import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/sin_camara.dart';

/// D3a Cámara de la solución (design.md §7, §10): pantalla oscura a visor completo,
/// sin guía de inclinación ni galería.
class CamaraSolucionScreen extends StatefulWidget {
  const CamaraSolucionScreen({super.key});

  @override
  State<CamaraSolucionScreen> createState() => _CamaraSolucionScreenState();
}

class _CamaraSolucionScreenState extends State<CamaraSolucionScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _inicializandoCamara = true;
  bool _sinCamara = false;
  bool _capturando = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _iniciarCamara();
  }

  Future<void> _iniciarCamara() async {
    setState(() {
      _inicializandoCamara = true;
      _sinCamara = false;
    });

    try {
      final camaras = await availableCameras();
      if (camaras.isEmpty) {
        if (!mounted) return;
        setState(() {
          _inicializandoCamara = false;
          _sinCamara = true;
        });
        return;
      }

      final trasera = camaras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => camaras.first,
      );

      final controller = CameraController(
        trasera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _cameraController = controller;
        _inicializandoCamara = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _inicializandoCamara = false;
        _sinCamara = true;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _iniciarCamara();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _disparar() async {
    final controller = _cameraController;
    if (_capturando || controller == null || !controller.value.isInitialized) {
      return;
    }

    setState(() => _capturando = true);
    try {
      final XFile archivo = await controller.takePicture();
      if (mounted) Navigator.of(context).pop(archivo.path);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo capturar la foto. Intenta de nuevo.')),
        );
      }
    } finally {
      if (mounted) setState(() => _capturando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_sinCamara) {
      return SinCamara(onReintentar: _iniciarCamara);
    }

    final controller = _cameraController;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (_inicializandoCamara)
              const Center(child: CircularProgressIndicator(color: AppColors.accent))
            else if (controller != null && controller.value.isInitialized)
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller.value.previewSize?.height ?? 1,
                  height: controller.value.previewSize?.width ?? 1,
                  child: CameraPreview(controller),
                ),
              )
            else
              const ColoredBox(color: Colors.black),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          key: const Key('cerrar_camara_solucion'),
                          tooltip: 'Cerrar',
                          icon: const Icon(Icons.close, color: Colors.white, size: 28),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'Toma una foto del trabajo terminado',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      key: const Key('disparador_solucion'),
                      onTap: _capturando ? null : _disparar,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          color: Colors.white,
                        ),
                        child: _capturando
                            ? const Center(
                                child: SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
