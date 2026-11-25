import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/aviso_push.dart';
import '../../domain/repositories/push_repository.dart';
import '../core/notificador_seguro.dart';

/// Escucha los push del rol con sesión (HU-12). Vive encima del shell de cada rol.
class PushViewModel extends ChangeNotifier with NotificadorSeguro {
  PushViewModel({required this._pushRepository});

  final PushRepository _pushRepository;
  final List<StreamSubscription<AvisoPush>> _suscripciones = [];
  AvisoPush? _porAbrir;
  AvisoPush? _recibido;

  /// Sube con cada aviso que llega con la app abierta: el punto naranja lo usa para recargar.
  int nuevos = 0;

  Future<void> iniciar() async {
    _suscripciones
      ..add(_pushRepository.tocados.listen(_abrir))
      ..add(_pushRepository.recibidos.listen((aviso) {
        _recibido = aviso;
        nuevos++;
        notifyListeners();
      }));
    final inicial = await _pushRepository.avisoInicial();
    if (inicial != null) _abrir(inicial);
  }

  /// El aviso que el usuario tocó, una sola vez, para que la vista navegue.
  AvisoPush? tomarPorAbrir() {
    final aviso = _porAbrir;
    _porAbrir = null;
    return aviso;
  }

  /// El aviso que llegó con la app abierta, una sola vez, para mostrar el snackbar.
  AvisoPush? tomarRecibido() {
    final aviso = _recibido;
    _recibido = null;
    return aviso;
  }

  void _abrir(AvisoPush aviso) {
    _porAbrir = aviso;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final s in _suscripciones) {
      s.cancel();
    }
    super.dispose();
  }
}
