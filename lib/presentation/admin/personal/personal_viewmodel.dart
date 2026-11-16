import 'package:flutter/foundation.dart';

import '../../../core/result.dart';
import '../../../domain/entities/operativo.dart';
import '../../../domain/repositories/admin_repository.dart';
import '../../core/estado_consulta.dart';
import '../../core/mensajes.dart';
import '../../core/notificador_seguro.dart';

enum FiltroPersonal { todos, activos, inactivos }

class PersonalViewModel extends ChangeNotifier with NotificadorSeguro {
  PersonalViewModel({required this._adminRepository});

  final AdminRepository _adminRepository;

  EstadoConsulta<List<Operativo>> estado = const Cargando();
  FiltroPersonal filtro = FiltroPersonal.todos;
  String busqueda = '';
  int? actualizandoId;
  String? error;

  List<Operativo> get operativos => switch (estado) {
    Listo(:final datos) => datos,
    _ => const [],
  };

  List<Operativo> get visibles {
    final consulta = busqueda.trim().toLowerCase();
    return operativos
        .where((operativo) {
          final coincideEstado = switch (filtro) {
            FiltroPersonal.todos => true,
            FiltroPersonal.activos => operativo.activo,
            FiltroPersonal.inactivos => !operativo.activo,
          };
          final coincideTexto =
              consulta.isEmpty ||
              '${operativo.nombreCompleto} ${operativo.correo}'
                  .toLowerCase()
                  .contains(consulta);
          return coincideEstado && coincideTexto;
        })
        .toList(growable: false);
  }

  Future<void> iniciar() => cargar();

  Future<void> cargar() async {
    if (estado is! Listo) {
      estado = const Cargando();
      notifyListeners();
    }

    final resultado = await _adminRepository.listarOperativos();
    estado = switch (resultado) {
      Ok(value: final datos) => Listo(datos),
      Error(error: final error) => ConError(mensajePara(error)),
    };
    notifyListeners();
  }

  void buscar(String valor) {
    busqueda = valor;
    notifyListeners();
  }

  void filtrar(FiltroPersonal valor) {
    filtro = valor;
    notifyListeners();
  }

  Future<bool> cambiarEstatus(Operativo operativo) async {
    actualizandoId = operativo.id;
    error = null;
    notifyListeners();
    final resultado = await _adminRepository.cambiarEstatusOperativo(
      operativo.id,
      activo: !operativo.activo,
    );
    actualizandoId = null;
    if (resultado case Error(error: final falla)) {
      error = mensajePara(falla);
      notifyListeners();
      return false;
    }

    await cargar();
    return true;
  }
}
