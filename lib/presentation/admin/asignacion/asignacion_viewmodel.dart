import 'package:flutter/foundation.dart';

import '../../../core/result.dart';
import '../../../domain/entities/incidencia_detalle.dart';
import '../../../domain/entities/operativo.dart';
import '../../../domain/repositories/admin_repository.dart';
import '../../../domain/repositories/direccion_repository.dart';
import '../../../domain/repositories/incidencias_repository.dart';
import '../../core/estado_consulta.dart';
import '../../core/mensajes.dart';
import '../../core/notificador_seguro.dart';

typedef DatosAsignacion = ({
  IncidenciaDetalle detalle,
  List<Operativo> operativos,
});

class AsignacionViewModel extends ChangeNotifier with NotificadorSeguro {
  factory AsignacionViewModel({
    required int id,
    required AdminRepository adminRepository,
    required DireccionRepository direccionRepository,
    required IncidenciasRepository incidenciasRepository,
  }) => AsignacionViewModel._(
    id,
    adminRepository,
    direccionRepository,
    incidenciasRepository,
  );

  AsignacionViewModel._(
    this.id,
    this._adminRepository,
    this._direccionRepository,
    this._incidenciasRepository,
  );

  final int id;
  final AdminRepository _adminRepository;
  final DireccionRepository _direccionRepository;
  final IncidenciasRepository _incidenciasRepository;

  EstadoConsulta<DatosAsignacion> estado = const Cargando();
  String? direccion;
  int? operativoSeleccionado;
  bool guardando = false;
  String? errorFormulario;

  bool get esReasignacion => switch (estado) {
    Listo(:final datos) => datos.detalle.resumen.operativo != null,
    _ => false,
  };

  Future<void> iniciar() async {
    estado = const Cargando();
    direccion = null;
    notifyListeners();
    final (detalle, operativos) = await (
      _incidenciasRepository.detalle(id),
      _adminRepository.operativosDisponibles(),
    ).wait;
    estado = switch ((detalle, operativos)) {
      (Ok(value: final d), Ok(value: final o)) => Listo((
        detalle: d,
        operativos: o,
      )),
      (Error(error: final e), _) ||
      (_, Error(error: final e)) => ConError(mensajePara(e)),
    };
    notifyListeners();
    if (estado case Listo(:final datos)) {
      direccion = await _direccionRepository.direccion(
        datos.detalle.resumen.latitud,
        datos.detalle.resumen.longitud,
      );
      if (direccion != null) notifyListeners();
    }
  }

  void seleccionar(int id) {
    operativoSeleccionado = id;
    errorFormulario = null;
    notifyListeners();
  }

  Future<bool> confirmar() async {
    if (operativoSeleccionado == null) {
      errorFormulario = 'Selecciona un operativo para continuar.';
      notifyListeners();
      return false;
    }
    guardando = true;
    errorFormulario = null;
    notifyListeners();
    final resultado = await _adminRepository.asignarIncidencia(
      id,
      operativoSeleccionado!,
    );
    guardando = false;
    if (resultado case Error(error: final e)) {
      errorFormulario = mensajePara(e);
      notifyListeners();
      return false;
    }
    notifyListeners();
    return true;
  }
}
