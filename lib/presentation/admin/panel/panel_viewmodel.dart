import 'package:flutter/foundation.dart';

import '../../../core/result.dart';
import '../../../domain/entities/estado_incidencia.dart';
import '../../../domain/entities/incidencia_resumen.dart';
import '../../../domain/entities/indicadores.dart';
import '../../../domain/entities/prioridad.dart';
import '../../../domain/repositories/admin_repository.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/incidence_type_repository.dart';
import '../../core/estado_consulta.dart';
import '../../core/mensajes.dart';
import '../../core/notificador_seguro.dart';

/// Lo que muestra E1: las cifras y hasta 5 de prioridad alta sin asignar.
typedef DatosPanel = ({Indicadores indicadores, List<IncidenciaResumen> prioritarias});

/// E1 Panel: indicadores (HU-19) y prioridad alta sin atender (HU-20).
class PanelViewModel extends ChangeNotifier with NotificadorSeguro {
  PanelViewModel({required this._adminRepository, required this._authRepository, this._tiposRepository});

  final AdminRepository _adminRepository;
  final AuthRepository _authRepository;

  /// Solo para el subtítulo de la fila «Catálogo de tipos»; sin él, la fila muestra el texto fijo.
  final IncidenceTypeRepository? _tiposRepository;

  static const maxPrioritarias = 5;

  String nombre = '';
  EstadoConsulta<DatosPanel> estado = const Cargando();

  /// «9 activos / 1 inactivo», o `null` si no se pudo leer el catálogo.
  String? resumenCatalogo;

  Future<void> iniciar() async {
    nombre = await _authRepository.nombreUsuario() ?? '';
    await (cargar(), cargarCatalogo()).wait;
  }

  /// Si falla no afecta al panel: la fila se queda sin las cifras.
  Future<void> cargarCatalogo() async {
    final repo = _tiposRepository;
    if (repo == null) return;
    if (await repo.catalogo() case Ok(value: final tipos)) {
      final activos = tipos.where((t) => t.activo).length;
      final inactivos = tipos.length - activos;
      resumenCatalogo =
          '$activos ${activos == 1 ? 'activo' : 'activos'} / $inactivos ${inactivos == 1 ? 'inactivo' : 'inactivos'}';
      notifyListeners();
    }
  }

  /// Al recargar se deja el panel actual a la vista hasta que llegan las cifras nuevas.
  Future<void> cargar() async {
    if (estado is! Listo) {
      estado = const Cargando();
      notifyListeners();
    }

    final (resIndicadores, resPrioritarias) = await (
      _adminRepository.indicadores(),
      _adminRepository.incidencias(
        prioridad: Prioridad.alta,
        estado: EstadoIncidencia.pendiente,
        tamano: maxPrioritarias,
      ),
    ).wait;

    estado = switch ((resIndicadores, resPrioritarias)) {
      (Ok(value: final i), Ok(value: final p)) => Listo((indicadores: i, prioritarias: p.contenido)),
      (Error(error: final falla), _) || (_, Error(error: final falla)) => ConError(mensajePara(falla)),
    };
    notifyListeners();
  }
}
