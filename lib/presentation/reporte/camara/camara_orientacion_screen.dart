import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/tipo_incidencia.dart';
import '../../../../domain/repositories/inclinacion_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/estado_vacio.dart';
import 'camara_orientacion_viewmodel.dart';
import 'resultado_captura.dart';
import 'widgets/barra_inclinacion.dart';
import 'widgets/reticula_encuadre.dart';

/// Pantalla B3 / B3b / B3c / B3d: Cámara en vivo con guía visual de inclinación (Issue #23 / HU-06).
///
/// La cámara cubre toda la pantalla. La guía muestra la zona verde según RN-11:
/// - Bache: hacia el suelo (≥ 45°).
/// - Luminaria: hacia arriba (≤ -20°).
/// - Fuga de agua: sin restricción (cualquier ángulo).
///
/// El botón disparador solo se habilita cuando el dispositivo entra en la zona verde.
class CamaraOrientacionScreen extends StatefulWidget {
  const CamaraOrientacionScreen({
    super.key,
    required this.tipo,
    this.precisionGps,
    this.sinSensor = false,
  });

  final TipoIncidencia tipo;
  final double? precisionGps;

  /// B2 ya sabe que el teléfono no tiene acelerómetro: se abre directo en B3e.
  final bool sinSensor;

  @override
  State<CamaraOrientacionScreen> createState() => _CamaraOrientacionScreenState();
}

class _CamaraOrientacionScreenState extends State<CamaraOrientacionScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _inicializandoCamara = true;
  /// No hay cámara o no hay permiso: se muestra B6 en lugar del visor (RN-09, RNF-03).
  bool _sinCamara = false;

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
        setState(() {
          _inicializandoCamara = false;
          _sinCamara = true;
        });
        return;
      }

      // Cámara trasera para fotos de evidencia (RN-09)
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

  Future<void> _disparar(CamaraOrientacionViewModel vm) async {
    final controller = _cameraController;
    if (!vm.disparadorActivo || controller == null || !controller.value.isInitialized) return;

    vm.setCapturando(true);
    try {
      // Promedio de ~0.5 s antes de disparar (RN-11); nunca un valor inventado
      final inclinacion = vm.inclinacionDelDisparo();
      final ahora = DateTime.now();
      final XFile archivo = await controller.takePicture();

      if (!mounted) return;
      Navigator.of(context).pop(
        ResultadoCaptura(
          rutaFoto: archivo.path,
          inclinacion: inclinacion,
          capturadaEn: ahora,
          sinSensor: vm.sinSensor,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo tomar la fotografía: $e')),
        );
      }
    } finally {
      if (mounted) {
        vm.setCapturando(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => CamaraOrientacionViewModel(
        tipo: widget.tipo,
        inclinacionRepository: ctx.read<InclinacionRepository>(),
        precisionGps: widget.precisionGps,
        sinSensor: widget.sinSensor,
      ),
      child: Consumer<CamaraOrientacionViewModel>(
        builder: (context, vm, _) {
          if (_sinCamara) return _SinCamara(onReintentar: _iniciarCamara);
          return Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Vista previa de la cámara (o visor simulado en emulador)
                _buildCameraPreview(),

                // 2. Retícula central con feedback de orientación
                Center(
                  child: ReticulaEncuadre(
                    enRango: vm.enRango,
                    orientacion: vm.tipo.orientacion,
                  ),
                ),

                // 3. Encabezado superior con botón cerrar y píldora informativa
                SafeArea(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                            tooltip: 'Cerrar',
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xB31F2937),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white24, width: 0.8),
                            ),
                            child: Text(
                              '${vm.tipo.nombre} • ${vm.subtituloOrientacion}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(width: 48), // Equilibrar el botón cerrar
                        ],
                      ),
                    ),
                  ),
                ),

                // 4. Panel inferior (Guía de inclinación + Disparador)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _buildBottomControls(vm),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_inicializandoCamara) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    final controller = _cameraController;
    if (controller != null && controller.value.isInitialized) {
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.previewSize?.height ?? 1,
          height: controller.value.previewSize?.width ?? 1,
          child: CameraPreview(controller),
        ),
      );
    }

    return const ColoredBox(color: Colors.black);
  }

  Widget _buildBottomControls(CamaraOrientacionViewModel vm) {
    final angulo = vm.anguloActual;
    final textoAngulo = vm.sinSensor ? '' : (angulo == null ? '--' : '${angulo.round()}°');
    final estadoColor = vm.enRango ? AppColors.guiaValida : AppColors.guiaInvalida;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Color(0xCC000000), Color(0xF2000000)],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tarjeta inferior de orientación y sensores
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xE614181D),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Fila 1: Título de estado y ángulo en grados
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      vm.estadoTexto,
                      style: TextStyle(
                        color: estadoColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      textoAngulo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Fila 2: Barra de inclinación (Cielo - Horizonte - Suelo)
                if (!vm.sinSensor && vm.tipo.orientacion != OrientacionFoto.sinRestriccion) ...[
                  BarraInclinacion(
                    angulo: vm.anguloActual,
                    orientacion: vm.tipo.orientacion,
                    enRango: vm.enRango,
                    anguloMin: vm.tipo.anguloMin,
                    anguloMax: vm.tipo.anguloMax,
                  ),
                  const SizedBox(height: 10),
                ],

                // Fila 3: Texto de ayuda / grados faltantes (si aplica)
                if (vm.textoAyuda != null) ...[
                  Text(
                    vm.textoAyuda!,
                    style: const TextStyle(
                      color: Color(0xFFD1D5DB),
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // Fila 4: Estado del GPS
                Row(
                  children: [
                    const Icon(Icons.gps_fixed_rounded, color: Color(0xFF9CA3AF), size: 14),
                    const SizedBox(width: 6),
                    Text(
                      vm.textoGps,
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Botón Disparador
          GestureDetector(
            key: const Key('disparador'),
            onTap: vm.disparadorActivo ? () => _disparar(vm) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: vm.disparadorActivo ? Colors.white : Colors.white38,
                  width: 4,
                ),
              ),
              padding: const EdgeInsets.all(4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: vm.disparadorActivo
                      ? AppColors.accent
                      : const Color(0x666B7280),
                ),
                child: vm.capturando
                    ? const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Texto de pie de página bajo el disparador
          Text(
            vm.textoPie,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// B6: la cámara no se pudo abrir (sin permiso o sin cámara). La foto debe ser en vivo, sin galería (RN-09).
class _SinCamara extends StatelessWidget {
  const _SinCamara({required this.onReintentar});

  final VoidCallback onReintentar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: EstadoVacio(
        icono: Icons.no_photography_outlined,
        titulo: 'No podemos usar la cámara',
        mensaje: 'La foto debe tomarse en este momento; no se puede elegir de la galería.',
        accion: 'Dar permiso',
        onAccion: onReintentar,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        ),
      ),
    );
  }
}
