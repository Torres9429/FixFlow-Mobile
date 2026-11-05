import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/result.dart';
import '../../domain/entities/reporte_nuevo.dart';
import '../../domain/entities/tipo_incidencia.dart';
import '../../domain/repositories/evidencia_repository.dart';
import '../../domain/repositories/incidence_type_repository.dart';
import '../../domain/repositories/inclinacion_repository.dart';
import '../../domain/repositories/reportes_ciudadano_repository.dart';
import '../core/mensajes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import 'revision/revision_reporte_screen.dart';
import 'revision/revision_reporte_viewmodel.dart';

/// B2 Nuevo reporte, paso 1 de 2: tipo y descripción. La foto se toma al continuar.
class NuevoReporteScreen extends StatefulWidget {
  const NuevoReporteScreen({super.key});

  @override
  State<NuevoReporteScreen> createState() => _NuevoReporteScreenState();
}

class _NuevoReporteScreenState extends State<NuevoReporteScreen> {
  static const _maxDescripcion = 500;

  final _formKey = GlobalKey<FormState>();
  final _descripcion = TextEditingController();
  final _picker = ImagePicker();
  List<TipoIncidencia> _tipos = const [];
  TipoIncidencia? _tipo;
  XFile? _foto;
  DateTime? _capturadaEn;
  Position? _posicion;
  bool _cargandoTipos = true;
  bool _cargandoUbicacion = true;
  String? _errorTipos;
  String? _errorUbicacion;

  @override
  void initState() {
    super.initState();
    _cargarTipos();
    _cargarUbicacion();
    _recuperarFotoPerdida();
  }

  @override
  void dispose() {
    _descripcion.dispose();
    super.dispose();
  }

  Future<void> _cargarTipos() async {
    setState(() {
      _cargandoTipos = true;
      _errorTipos = null;
    });
    final res = await context.read<IncidenceTypeRepository>().obtenerTipos();
    if (!mounted) return;
    setState(() {
      _cargandoTipos = false;
      switch (res) {
        case Ok(:final value):
          _tipos = value;
        case Error(error: final falla):
          _errorTipos = mensajePara(falla);
      }
    });
  }

  Future<void> _cargarUbicacion() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw const FormatException('GPS desactivado');
      }
      var permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }
      if (permiso == LocationPermission.denied || permiso == LocationPermission.deniedForever) {
        throw const FormatException('Permiso de ubicación denegado');
      }
      final posicion = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _posicion = posicion;
        _cargandoUbicacion = false;
        _errorUbicacion = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _cargandoUbicacion = false;
        _errorUbicacion = 'No se pudo obtener la ubicación GPS.';
      });
    }
  }

  Future<XFile?> _capturarFoto() async {
    try {
      final foto = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
      if (!mounted || foto == null) return null;
      setState(() {
        _foto = foto;
        _capturadaEn = DateTime.now();
      });
      return foto;
    } catch (_) {
      if (mounted) _mostrarAviso('No se pudo abrir la cámara. Verifica el permiso.');
      return null;
    }
  }

  /// Si Android cerró la app mientras la cámara estaba abierta, recupera la foto tomada.
  Future<void> _recuperarFotoPerdida() async {
    try {
      final respuesta = await _picker.retrieveLostData();
      if (!mounted || respuesta.isEmpty) return;
      final archivos = respuesta.files;
      if (archivos != null && archivos.isNotEmpty) {
        final recuperada = archivos.first;
        final fecha = await recuperada.lastModified();
        if (!mounted) return;
        setState(() {
          _foto = recuperada;
          _capturadaEn = fecha;
        });
        return;
      }
      if (respuesta.exception != null) {
        _mostrarAviso('No se pudo recuperar la captura de la cámara.');
      }
    } catch (_) {
      if (mounted) _mostrarAviso('No se pudo recuperar la captura de la cámara.');
    }
  }

  void _mostrarAviso(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  /// Valida el paso 1, abre la cámara (o usa la foto recuperada) y pasa a revisar.
  Future<void> _continuar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final tipo = _tipo;
    if (tipo == null) return;

    final posicion = _posicion;
    if (posicion == null) {
      _mostrarAviso(
        _cargandoUbicacion
            ? 'Todavía estamos obteniendo tu ubicación. Intenta en un momento.'
            : 'La ubicación GPS es obligatoria para enviar el reporte. Actívala e intenta de nuevo.',
      );
      if (_errorUbicacion != null) _cargarUbicacion();
      return;
    }

    // Se leen antes de los await para no usar el context después
    final inclinacionRepository = context.read<InclinacionRepository>();
    final evidenciaRepository = context.read<EvidenciaRepository>();
    final reportesRepository = context.read<ReportesCiudadanoRepository>();

    final foto = _foto ?? await _capturarFoto();
    if (!mounted || foto == null) return;
    // PROVISIONAL: con la cámara en vivo (#20/#23) la inclinación será la del momento del disparo
    final inclinacion = await inclinacionRepository.leerInclinacion();
    if (!mounted) return;

    final reporte = ReporteNuevo(
      tipo: tipo,
      descripcion: _descripcion.text.trim(),
      latitud: posicion.latitude,
      longitud: posicion.longitude,
      inclinacion: inclinacion,
      rutaFoto: foto.path,
      capturadaEn: _capturadaEn ?? DateTime.now(),
    );
    final repetirFoto = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => RevisionReporteViewModel(
            reporte: reporte,
            evidenciaRepository: evidenciaRepository,
            reportesRepository: reportesRepository,
          ),
          child: const RevisionReporteScreen(),
        ),
      ),
    );
    if (!mounted) return;
    // Al regresar de revisar, la siguiente vez se toma una foto nueva
    setState(() => _foto = null);
    // «Repetir foto» en B4: se vuelve a abrir la cámara con el mismo tipo y descripción
    if (repetirFoto == true) await _continuar();
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final tituloSeccion = texto.titleMedium?.copyWith(fontSize: 17, height: 24 / 17, fontWeight: FontWeight.w700);
    final meta = texto.bodySmall?.copyWith(
      fontSize: 13,
      height: 18 / 13,
      fontWeight: FontWeight.w500,
      color: AppColors.textMuted,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(tooltip: 'Regresar', icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const Text('Nuevo reporte'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Row(
              children: [
                Text('Paso 1 de 2', style: meta?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                const _Progreso(),
              ],
            ),
            const SizedBox(height: 20),
            Text('Tipo de incidencia', style: tituloSeccion),
            const SizedBox(height: 4),
            Text(
              'Selecciona la categoría que mejor describa la situación',
              style: texto.bodyLarge?.copyWith(fontSize: 15, height: 22 / 15, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            if (_cargandoTipos)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_errorTipos != null)
              _ErrorRow(mensaje: _errorTipos!, onRetry: _cargarTipos)
            else ...[
              _TipoElegido(tipo: _tipo),
              const SizedBox(height: 12),
              _CuadriculaTipos(tipos: _tipos, elegido: _tipo, onElegir: (tipo) => setState(() => _tipo = tipo)),
              FormField<TipoIncidencia>(
                validator: (_) => _tipo == null ? 'Selecciona un tipo de incidencia' : null,
                builder: (field) => field.hasError
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(field.errorText!, style: meta?.copyWith(color: AppColors.error)),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(child: Text('Descripción', style: tituloSeccion)),
                Text('Obligatoria', style: meta),
              ],
            ),
            const SizedBox(height: 12),
            _CampoDescripcion(controller: _descripcion, maximo: _maxDescripcion),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: Text('Sé específico para facilitar la atención', style: meta)),
                ValueListenableBuilder(
                  valueListenable: _descripcion,
                  builder: (_, valor, _) => Text(
                    '${valor.text.length}/$_maxDescripcion',
                    style: meta?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Aviso corto de lo que sigue; el detalle de la captura vive en la cámara
            Row(
              children: [
                const Icon(Icons.photo_camera_outlined, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(child: Text('Al continuar se abre la cámara con guía de inclinación y GPS.', style: meta)),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(color: AppColors.surface, boxShadow: AppTheme.sombraBarraInferior),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: FilledButton(
              key: const Key('reporte_revisar_enviar'),
              onPressed: _continuar,
              child: const Text('Continuar a captura'),
            ),
          ),
        ),
      ),
    );
  }
}

/// Barra de pasos: el paso 1 largo y en azul, el 2 corto y gris.
class _Progreso extends StatelessWidget {
  const _Progreso();

  @override
  Widget build(BuildContext context) {
    Widget paso(double ancho, Color color) => Container(
      width: ancho,
      height: 6,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [paso(28, AppColors.primary), const SizedBox(width: 6), paso(8, AppColors.borderSubtle)],
    );
  }
}

/// Icono de cada tipo del catálogo; los tipos nuevos usan el genérico.
IconData _iconoTipo(String codigo) => switch (codigo) {
  'BACHE' => Icons.texture,
  'LUMINARIA' => Icons.lightbulb_outline,
  'FUGA_AGUA' => Icons.water_drop_outlined,
  'COLADERA' => Icons.grid_on,
  'ARBOL_CAIDO' => Icons.park_outlined,
  'SENALAMIENTO' => Icons.signpost_outlined,
  'BANQUETA' => Icons.directions_walk,
  'BASURA' => Icons.delete_outline,
  _ => Icons.report_outlined,
};

String _pistaOrientacion(OrientacionFoto orientacion) => switch (orientacion) {
  OrientacionFoto.suelo => 'La foto se toma apuntando hacia el suelo',
  OrientacionFoto.arriba => 'La foto se toma apuntando hacia arriba',
  OrientacionFoto.sinRestriccion => 'Cualquier ángulo; la inclinación se guarda con la foto',
};

/// Tarjeta con el tipo elegido y cómo se tomará la foto.
class _TipoElegido extends StatelessWidget {
  const _TipoElegido({required this.tipo});

  final TipoIncidencia? tipo;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final tipo = this.tipo;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        boxShadow: AppTheme.sombra,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tipo?.nombre ?? 'Ningún tipo elegido',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: texto.titleMedium?.copyWith(
                    fontSize: 16,
                    height: 22 / 16,
                    fontWeight: FontWeight.w700,
                    color: tipo == null ? AppColors.textMuted : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tipo == null ? 'Elige una opción de la lista' : _pistaOrientacion(tipo.orientacion),
                  style: texto.bodySmall?.copyWith(
                    fontSize: 13,
                    height: 18 / 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: AppColors.surfaceMuted, shape: BoxShape.circle),
            child: Icon(
              tipo == null ? Icons.category_outlined : _iconoTipo(tipo.codigo),
              size: 22,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Cuadrícula de 2 columnas con todos los tipos activos.
class _CuadriculaTipos extends StatelessWidget {
  const _CuadriculaTipos({required this.tipos, required this.elegido, required this.onElegir});

  final List<TipoIncidencia> tipos;
  final TipoIncidencia? elegido;
  final ValueChanged<TipoIncidencia> onElegir;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, restricciones) {
        final ancho = (restricciones.maxWidth - 8) / 2;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tipo in tipos)
              SizedBox(
                width: ancho,
                child: _ChipTipo(tipo: tipo, activo: tipo.id == elegido?.id, onTap: () => onElegir(tipo)),
              ),
          ],
        );
      },
    );
  }
}

class _ChipTipo extends StatelessWidget {
  const _ChipTipo({required this.tipo, required this.activo, required this.onTap});

  final TipoIncidencia tipo;
  final bool activo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radio = BorderRadius.circular(12);
    final color = activo ? Colors.white : AppColors.textPrimary;

    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: radio, boxShadow: AppTheme.sombra),
      child: Material(
        color: activo ? AppColors.primary : AppColors.surface,
        borderRadius: radio,
        child: InkWell(
          key: Key('tipo_${tipo.id}'),
          borderRadius: radio,
          onTap: onTap,
          child: Semantics(
            selected: activo,
            child: SizedBox(
              height: 48,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(_iconoTipo(tipo.codigo), size: 18, color: activo ? Colors.white : AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tipo.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: color),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Descripción en una tarjeta blanca, sin borde de campo; el contador va afuera.
class _CampoDescripcion extends StatelessWidget {
  const _CampoDescripcion({required this.controller, required this.maximo});

  final TextEditingController controller;
  final int maximo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        boxShadow: AppTheme.sombra,
      ),
      child: TextFormField(
        key: const Key('reporte_descripcion'),
        controller: controller,
        minLines: 3,
        maxLines: 6,
        maxLength: maximo,
        textCapitalization: TextCapitalization.sentences,
        validator: (value) => value == null || value.trim().isEmpty ? 'Campo obligatorio' : null,
        decoration: const InputDecoration(
          hintText: 'Añade detalles relevantes como referencias visuales…',
          filled: false,
          isDense: true,
          contentPadding: EdgeInsets.zero,
          counterText: '',
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
        ),
      ),
    );
  }
}

class _ErrorRow extends StatelessWidget {
  const _ErrorRow({required this.mensaje, required this.onRetry});
  final String mensaje;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(mensaje, style: const TextStyle(color: AppColors.error)),
      ),
      IconButton(tooltip: 'Reintentar', onPressed: onRetry, icon: const Icon(Icons.refresh)),
    ],
  );
}
