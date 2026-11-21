import 'package:flutter/foundation.dart';

import '../../../core/result.dart';
import '../../../domain/entities/coordenada.dart';
import '../../../domain/errors/falla_red.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/evidencia_repository.dart';
import '../../../domain/repositories/operativo_repository.dart';
import '../../../domain/repositories/ubicacion_repository.dart';
import '../../../domain/validators/campos_validators.dart';
import '../../core/mensajes.dart';
import '../../core/notificador_seguro.dart';

enum PasoEnvioSolucion { listo, subiendoFoto, enviando }

/// D3 Registrar solución (HU-16 / RF-18 / #70): sube la foto como `SOLUCION` y transita a `RESUELTA`.
class SolucionViewModel extends ChangeNotifier with NotificadorSeguro {
  SolucionViewModel({
    required this.id,
    required this._operativoRepository,
    required this._evidenciaRepository,
    required this._ubicacionRepository,
    required this._authRepository,
  });

  static const maxDescripcion = 500;

  final int id;
  final OperativoRepository _operativoRepository;
  final EvidenciaRepository _evidenciaRepository;
  final UbicacionRepository _ubicacionRepository;
  final AuthRepository _authRepository;

  String nombreOperativo = '';
  String? rutaFoto;
  DateTime? capturadaEn;
  String descripcion = '';
  PasoEnvioSolucion paso = PasoEnvioSolucion.listo;
  String? errorFoto;
  String? errorDescripcion;
  String? errorGeneral;
  bool enviada = false;

  /// URL ya subida en Cloudinary: si falla el registro posterior, el reintento no vuelve a subir (RNF-08).
  String? _fotoUrl;

  /// GPS del momento de la foto: se pide al capturar, no al enviar, para que sea el lugar del trabajo.
  Future<Coordenada?>? _posicion;

  bool get enviando => paso != PasoEnvioSolucion.listo;

  Future<void> iniciar() async {
    final nombre = await _authRepository.nombreUsuario();
    if (nombre != null && nombre.isNotEmpty) {
      nombreOperativo = nombre;
      notifyListeners();
    }
  }

  void establecerFoto(String ruta, {DateTime? capturadaEn}) {
    rutaFoto = ruta;
    this.capturadaEn = capturadaEn ?? DateTime.now();
    _fotoUrl = null;
    _posicion = _ubicacionRepository.posicionActual();
    errorFoto = null;
    errorGeneral = null;
    notifyListeners();
  }

  void cambiarDescripcion(String valor) {
    descripcion = valor;
    errorDescripcion = null;
    errorGeneral = null;
    notifyListeners();
  }

  Future<bool> enviar() async {
    if (enviando) return false;

    errorFoto = rutaFoto == null ? 'Toma una foto del trabajo terminado' : null;
    errorDescripcion = validarDescripcionSolucion(descripcion);
    errorGeneral = null;
    if (errorFoto != null || errorDescripcion != null) {
      notifyListeners();
      return false;
    }

    var fotoUrl = _fotoUrl;
    if (fotoUrl == null) {
      paso = PasoEnvioSolucion.subiendoFoto;
      notifyListeners();
      final subida = await _evidenciaRepository.subirFoto(
        rutaFoto!,
        tipo: TipoEvidencia.solucion,
      );
      if (subida case Error(error: final falla)) {
        errorGeneral = mensajePara(falla);
        paso = PasoEnvioSolucion.listo;
        notifyListeners();
        return false;
      }
      fotoUrl = _fotoUrl = (subida as Ok<String>).value;
    }

    paso = PasoEnvioSolucion.enviando;
    notifyListeners();

    // Normalmente ya llegó mientras el operativo escribía la descripción
    final posicion = await (_posicion ?? _ubicacionRepository.posicionActual());
    final res = await _operativoRepository.registrarSolucion(
      incidenciaId: id,
      descripcion: descripcion.trim(),
      fotoUrl: fotoUrl,
      latitud: posicion?.latitud,
      longitud: posicion?.longitud,
    );

    if (res is Ok) {
      enviada = true;
      paso = PasoEnvioSolucion.listo;
      notifyListeners();
      return true;
    }

    final falla = (res as Error).error;
    if (falla is EvidenciaInvalida) _fotoUrl = null;
    errorGeneral = mensajePara(falla);
    paso = PasoEnvioSolucion.listo;
    notifyListeners();
    return false;
  }
}
