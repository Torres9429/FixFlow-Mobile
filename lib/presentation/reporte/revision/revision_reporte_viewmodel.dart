import 'package:flutter/foundation.dart';

import '../../../core/result.dart';
import '../../../domain/entities/reporte_creado.dart';
import '../../../domain/entities/reporte_nuevo.dart';
import '../../../domain/errors/falla_red.dart';
import '../../../domain/repositories/evidencia_repository.dart';
import '../../../domain/repositories/reportes_ciudadano_repository.dart';
import '../../../domain/validators/evidencia_validator.dart';
import '../../core/mensajes.dart';
import '../../core/notificador_seguro.dart';

enum PasoEnvio { listo, subiendoFoto, enviando }

/// B4 Revisar y enviar (HU-03, HU-08): valida la evidencia (RN-12), sube la foto y crea el reporte.
class RevisionReporteViewModel extends ChangeNotifier with NotificadorSeguro {
  RevisionReporteViewModel({
    required this.reporte,
    required this._evidenciaRepository,
    required this._reportesRepository,
  });

  final ReporteNuevo reporte;
  final EvidenciaRepository _evidenciaRepository;
  final ReportesCiudadanoRepository _reportesRepository;

  PasoEnvio paso = PasoEnvio.listo;
  String? error;

  /// El back rechazó la evidencia (422): hay que volver a capturar, reintentar no sirve.
  bool pideRepetir = false;

  /// Listo cuando el back creó el reporte; la pantalla navega a B5.
  ReporteCreado? creado;

  /// La foto ya subida: si después falla el envío, el reintento no la vuelve a subir (RNF-08).
  String? _fotoUrl;

  /// Motivo por el que no se puede enviar todavía, o `null` si la evidencia es válida.
  String? get problema => validarEvidencia(reporte);

  bool get ocupado => paso != PasoEnvio.listo;

  Future<void> enviar() async {
    if (problema != null || ocupado) return;
    error = null;
    pideRepetir = false;

    var fotoUrl = _fotoUrl;
    if (fotoUrl == null) {
      paso = PasoEnvio.subiendoFoto;
      notifyListeners();
      final subida = await _evidenciaRepository.subirFoto(reporte.rutaFoto);
      if (subida case Error(error: final falla)) return _fallo(falla);
      fotoUrl = _fotoUrl = (subida as Ok<String>).value;
    }

    paso = PasoEnvio.enviando;
    notifyListeners();
    switch (await _reportesRepository.crear(reporte, fotoUrl)) {
      case Ok(:final value):
        creado = value;
        paso = PasoEnvio.listo;
        notifyListeners();
      case Error(error: final falla):
        _fallo(falla);
    }
  }

  void _fallo(Object falla) {
    error = mensajePara(falla);
    pideRepetir = falla is EvidenciaInvalida;
    paso = PasoEnvio.listo;
    notifyListeners();
  }
}
