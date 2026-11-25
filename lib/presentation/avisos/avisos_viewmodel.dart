import 'package:flutter/foundation.dart';

import '../../core/result.dart';
import '../../domain/entities/aviso.dart';
import '../../domain/repositories/avisos_repository.dart';
import '../core/estado_consulta.dart';
import '../core/mensajes.dart';
import '../core/notificador_seguro.dart';

/// C1, D6 y E7 Avisos (HU-12): la bandeja del rol con sesión, agrupada en Hoy / Esta semana / Anteriores.
class AvisosViewModel extends ChangeNotifier with NotificadorSeguro {
  AvisosViewModel({required this._avisosRepository, DateTime Function()? ahora}) : _ahora = ahora ?? DateTime.now;

  final AvisosRepository _avisosRepository;
  final DateTime Function() _ahora;

  EstadoConsulta<List<Aviso>> estado = const Cargando();
  bool cargandoMas = false;
  bool marcandoTodos = false;
  int _pagina = 0;
  bool _esUltima = true;
  int? _ultimoContador;

  List<Aviso> get avisos => switch (estado) {
    Listo(:final datos) => datos,
    _ => const [],
  };

  bool get hayNoLeidos => avisos.any((a) => !a.leida);

  /// Grupos sin los vacíos, en orden: «Hoy», «Esta semana» (últimos 7 días) y «Anteriores».
  List<(String, List<Aviso>)> get grupos {
    final ahora = _ahora();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final haceUnaSemana = hoy.subtract(const Duration(days: 6));
    final (hoyLista, semana, anteriores) = (<Aviso>[], <Aviso>[], <Aviso>[]);
    for (final a in avisos) {
      final dia = DateTime(a.fecha.year, a.fecha.month, a.fecha.day);
      if (!dia.isBefore(hoy)) {
        hoyLista.add(a);
      } else if (!dia.isBefore(haceUnaSemana)) {
        semana.add(a);
      } else {
        anteriores.add(a);
      }
    }
    return [
      if (hoyLista.isNotEmpty) ('Hoy', hoyLista),
      if (semana.isNotEmpty) ('Esta semana', semana),
      if (anteriores.isNotEmpty) ('Anteriores', anteriores),
    ];
  }

  /// Al recargar se deja la lista actual a la vista hasta que llega la nueva.
  Future<void> cargar() async {
    if (estado is! Listo) {
      estado = const Cargando();
      notifyListeners();
    }
    final res = await _avisosRepository.avisos();
    switch (res) {
      case Ok(:final value):
        estado = Listo(value.contenido);
        _pagina = value.numero;
        _esUltima = value.esUltima;
      case Error(error: final falla):
        estado = ConError(mensajePara(falla));
    }
    notifyListeners();
  }

  Future<void> cargarMas() async {
    if (_esUltima || estado is! Listo || cargandoMas) return;
    cargandoMas = true;
    notifyListeners();
    final res = await _avisosRepository.avisos(pagina: _pagina + 1);
    if (res case Ok(:final value)) {
      estado = Listo([...avisos, ...value.contenido]);
      _pagina = value.numero;
      _esUltima = value.esUltima;
    }
    cargandoMas = false;
    notifyListeners();
  }

  /// Al tocar un aviso: se ve leído de inmediato y se avisa al back. Si falla, solo vuelve el punto.
  Future<void> marcarLeido(Aviso aviso) async {
    if (aviso.leida) return;
    _reemplazar(aviso.id, aviso.leido());
    final res = await _avisosRepository.marcarLeido(aviso.id);
    if (res is Error) _reemplazar(aviso.id, aviso);
  }

  /// «Marcar todo como leído». Devuelve el resultado para que la vista muestre el error.
  Future<Result<void>> marcarTodos() async {
    if (marcandoTodos || !hayNoLeidos) return const Result.ok(null);
    marcandoTodos = true;
    notifyListeners();
    final res = await _avisosRepository.marcarTodosLeidos();
    if (res is Ok) estado = Listo([for (final a in avisos) a.leido()]);
    marcandoTodos = false;
    notifyListeners();
    return res;
  }

  /// El contador del shell cambió (push o al volver a la app): si subió, llegaron avisos nuevos.
  void sincronizar(int? noLeidosDelServidor) {
    if (noLeidosDelServidor == null) return;
    final anterior = _ultimoContador;
    _ultimoContador = noLeidosDelServidor;
    if (anterior != null && noLeidosDelServidor > anterior && estado is Listo) cargar();
  }

  void _reemplazar(int id, Aviso nuevo) {
    estado = Listo([for (final a in avisos) a.id == id ? nuevo : a]);
    notifyListeners();
  }
}
