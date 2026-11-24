import 'package:flutter/foundation.dart';

import '../../../core/result.dart';
import '../../../domain/errors/falla_red.dart';
import '../../../domain/repositories/reportes_ciudadano_repository.dart';
import '../../../domain/validators/campos_validators.dart';
import '../../core/mensajes.dart';
import '../../core/notificador_seguro.dart';

/// C3 Reabrir reporte (HU-23 / RN-17): el ciudadano explica qué sigue mal y la incidencia pasa a Reabierta.
class ReabrirReporteViewModel extends ChangeNotifier with NotificadorSeguro {
  ReabrirReporteViewModel({required this.id, required this._reportesRepository});

  static const maxJustificacion = 500;

  final int id;
  final ReportesCiudadanoRepository _reportesRepository;

  String justificacion = '';
  bool reabriendo = false;
  String? errorJustificacion;
  String? errorGeneral;

  void cambiarJustificacion(String valor) {
    justificacion = valor;
    errorJustificacion = null;
    errorGeneral = null;
    notifyListeners();
  }

  /// Envía la reapertura. Devuelve el texto del servidor; si falla, deja [errorGeneral] listo para pintar.
  Future<Result<String>> reabrir() async {
    if (reabriendo) return const Result.error(Conflicto('Ya se está reabriendo'));
    errorJustificacion = validarJustificacionReapertura(justificacion);
    errorGeneral = null;
    if (errorJustificacion != null) {
      notifyListeners();
      return const Result.error(PeticionRechazada(400));
    }
    reabriendo = true;
    notifyListeners();
    final res = await _reportesRepository.reabrir(id, justificacion.trim());
    reabriendo = false;
    if (res case Error(error: final falla)) errorGeneral = mensajePara(falla);
    notifyListeners();
    return res;
  }
}
