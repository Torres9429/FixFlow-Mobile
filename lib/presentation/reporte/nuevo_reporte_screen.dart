import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/tipo_incidencia.dart';
import '../../domain/repositories/incidence_type_repository.dart';
import '../core/theme/app_colors.dart';
import '../routing/rutas.dart';

class NuevoReporteScreen extends StatefulWidget {
  const NuevoReporteScreen({super.key});

  @override
  State<NuevoReporteScreen> createState() => _NuevoReporteScreenState();
}

class _NuevoReporteScreenState extends State<NuevoReporteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descripcion = TextEditingController();
  final _picker = ImagePicker();
  List<TipoIncidencia> _tipos = const [];
  TipoIncidencia? _tipo;
  XFile? _foto;
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
  }

  @override
  void dispose() {
    _descripcion.dispose();
    super.dispose();
  }

  Future<void> _cargarTipos() async {
    try {
      final tipos = await context.read<IncidenceTypeRepository>().obtenerTipos();
      if (!mounted) return;
      setState(() {
        _tipos = tipos;
        _cargandoTipos = false;
        _errorTipos = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _cargandoTipos = false;
        _errorTipos = 'No se pudieron cargar los tipos de incidencia.';
      });
    }
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

  Future<void> _capturarFoto() async {
    try {
      final foto = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
      if (!mounted || foto == null) return;
      setState(() => _foto = foto);
    } catch (_) {
      if (!mounted) return;
      _mostrarAviso('No se pudo abrir la cámara. Verifica el permiso.');
    }
  }

  void _mostrarAviso(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  void _revisar() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_foto == null) {
      _mostrarAviso('Agrega evidencia fotográfica antes de continuar.');
      return;
    }
    if (_posicion == null) {
      _mostrarAviso('La ubicación GPS es obligatoria para enviar el reporte.');
      return;
    }
    final tipo = _tipo;
    final foto = _foto;
    final posicion = _posicion;
    if (tipo == null || foto == null || posicion == null) {
      _mostrarAviso('Completa el tipo, la evidencia y la ubicación antes de continuar.');
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => RevisionReporteScreen(
        tipo: tipo,
        descripcion: _descripcion.text.trim(),
        foto: foto,
        posicion: posicion,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Regresar',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Nuevo reporte'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          children: [
            Text('Tipo de incidencia', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            if (_cargandoTipos)
              const Center(child: CircularProgressIndicator())
            else if (_errorTipos != null)
              _ErrorRow(mensaje: _errorTipos!, onRetry: _cargarTipos)
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _tipos.map((tipo) => ChoiceChip(
                  key: Key('tipo_${tipo.id}'),
                  label: Text(tipo.nombre),
                  selected: _tipo?.id == tipo.id,
                  onSelected: (_) => setState(() => _tipo = tipo),
                )).toList(),
              ),
            if (!_cargandoTipos && _errorTipos == null)
              FormField<TipoIncidencia>(
                initialValue: _tipo,
                validator: (_) => _tipo == null ? 'Selecciona un tipo de incidencia' : null,
                builder: (field) => field.hasError
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8, left: 12),
                        child: Text(field.errorText!, style: TextStyle(color: AppColors.error)),
                      )
                    : const SizedBox.shrink(),
              ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Evidencia', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                TextButton.icon(
                  onPressed: _capturarFoto,
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: Text(_foto == null ? 'Abrir cámara' : 'Repetir captura'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _EvidencePreview(foto: _foto, onTap: _capturarFoto),
            const SizedBox(height: 18),
            _StatusRow(
              label: 'Tomada con la cámara',
              value: _foto == null ? 'Pendiente' : 'Capturada',
              ok: _foto != null,
            ),
            _StatusRow(label: 'Ubicación GPS', value: _cargandoUbicacion ? 'Obteniendo…' : _posicion == null ? 'No disponible' : '${_posicion!.latitude.toStringAsFixed(4)}, ${_posicion!.longitude.toStringAsFixed(4)}', ok: _posicion != null),
            if (_errorUbicacion != null)
              TextButton.icon(onPressed: _cargarUbicacion, icon: const Icon(Icons.refresh), label: const Text('Reintentar ubicación')),
            const SizedBox(height: 22),
            Text('Descripción del problema', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            TextFormField(
              key: const Key('reporte_descripcion'),
              controller: _descripcion,
              minLines: 4,
              maxLines: 6,
              maxLength: 500,
              validator: (value) => value == null || value.trim().isEmpty ? 'Campo obligatorio' : null,
              decoration: const InputDecoration(hintText: 'Describe el problema con el mayor detalle posible.'),
            ),
            const SizedBox(height: 4),
            Text('La fecha y hora se registran automáticamente al enviar.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 28),
            FilledButton(
              key: const Key('reporte_revisar_enviar'),
              onPressed: _revisar,
              child: const Text('Revisar y enviar'),
            ),
          ],
        ),
      ),
    );
  }
}

class RevisionReporteScreen extends StatelessWidget {
  const RevisionReporteScreen({super.key, required this.tipo, required this.descripcion, required this.foto, required this.posicion});

  final TipoIncidencia tipo;
  final String descripcion;
  final XFile foto;
  final Position posicion;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Revisar reporte')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Confirma la información', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          _ReviewItem(label: 'Tipo de incidencia', value: tipo.nombre),
          _ReviewItem(label: 'Descripción', value: descripcion),
          _ReviewItem(label: 'Ubicación GPS', value: '${posicion.latitude}, ${posicion.longitude}'),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(File(foto.path), height: 190, fit: BoxFit.cover),
          ),
          const SizedBox(height: 26),
          FilledButton(
            key: const Key('reporte_confirmar'),
            onPressed: () {
              final id = 'INC-${DateTime.now().microsecondsSinceEpoch}';
              showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (_) => AlertDialog(
                  title: const Text('Reporte enviado'),
                  content: Text('Tu reporte fue registrado con el identificador $id.'),
                  actions: [TextButton(onPressed: () => context.go(Rutas.homeCiudadano), child: const Text('Aceptar'))],
                ),
              );
            },
            child: const Text('Confirmar y enviar'),
          ),
        ],
      ),
    );
  }
}

class _EvidencePreview extends StatelessWidget {
  const _EvidencePreview({required this.foto, required this.onTap});
  final XFile? foto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: 190,
            child: foto == null
                ? Container(
                    color: AppColors.primaryDark,
                    child: const Center(child: Icon(Icons.camera_alt_outlined, color: Colors.white, size: 46)),
                  )
                : Image.file(File(foto!.path), fit: BoxFit.cover),
          ),
        ),
      );
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.value, required this.ok});
  final String label;
  final String value;
  final bool ok;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(ok ? Icons.check_circle : Icons.radio_button_unchecked, color: ok ? AppColors.resuelta : AppColors.textMuted),
        title: Text(label),
        trailing: Text(value, style: TextStyle(color: ok ? AppColors.textSecondary : AppColors.textMuted)),
      );
}

class _ErrorRow extends StatelessWidget {
  const _ErrorRow({required this.mensaje, required this.onRetry});
  final String mensaje;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(child: Text(mensaje, style: const TextStyle(color: AppColors.error))),
        IconButton(onPressed: onRetry, icon: const Icon(Icons.refresh)),
      ]);
}

class _ReviewItem extends StatelessWidget {
  const _ReviewItem({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ]),
      );
}
