import 'package:flutter/foundation.dart';

import '../../../core/result.dart';
import '../../../domain/entities/prioridad.dart';
import '../../../domain/entities/tipo_incidencia.dart';
import '../../../domain/errors/falla_red.dart';
import '../../../domain/repositories/incidence_type_repository.dart';
import '../../../domain/validators/campos_validators.dart';
import '../../core/mensajes.dart';
import '../../core/notificador_seguro.dart';

/// E11 Nuevo tipo y E12 Editar tipo, con E12a (desactivar) y la reactivación (HU-26).
class TipoFormViewModel extends ChangeNotifier with NotificadorSeguro {
  TipoFormViewModel({required this._tiposRepository, this.tipo})
    : nombre = tipo?.nombre ?? '',
      codigo = tipo?.codigo ?? '',
      orientacion = tipo?.orientacion,
      prioridad = tipo?.prioridadBase;

  final IncidenceTypeRepository _tiposRepository;

  /// El tipo que se edita; `null` en el alta.
  final TipoIncidencia? tipo;

  String nombre;
  String codigo;
  OrientacionFoto? orientacion;
  Prioridad? prioridad;

  /// «Activo inmediatamente» en E11. El back crea los tipos activos; si se apaga, se desactiva después de crearlo.
  bool activoAlCrear = true;

  bool guardando = false;
  String? errorNombre;
  String? errorCodigo;
  String? errorOrientacion;
  String? errorPrioridad;

  /// Falla que no es de un campo; la pantalla la muestra en un snackbar.
  String? errorGeneral;

  bool get esEdicion => tipo != null;

  /// Debajo del código en E11: «Si lo dejas vacío se usará FUGA_DE_AGUA. No se puede cambiar después».
  String get ayudaCodigo {
    final sugerido = codigoSugerido(nombre);
    return sugerido.isEmpty
        ? 'Si lo dejas vacío se genera del nombre. No se puede cambiar después'
        : 'Si lo dejas vacío se usará $sugerido. No se puede cambiar después';
  }

  void cambiarNombre(String valor) {
    nombre = valor;
    errorNombre = null;
    notifyListeners();
  }

  void cambiarCodigo(String valor) {
    codigo = valor;
    errorCodigo = null;
    notifyListeners();
  }

  void elegirOrientacion(OrientacionFoto valor) {
    orientacion = valor;
    errorOrientacion = null;
    notifyListeners();
  }

  void elegirPrioridad(Prioridad valor) {
    prioridad = valor;
    errorPrioridad = null;
    notifyListeners();
  }

  void cambiarActivoAlCrear(bool valor) {
    activoAlCrear = valor;
    notifyListeners();
  }

  /// Crea o edita el tipo. Devuelve `true` si el servidor lo guardó.
  Future<bool> guardar() async {
    errorNombre = validarNombreTipo(nombre);
    errorCodigo = esEdicion ? null : validarCodigoTipo(codigo);
    errorOrientacion = orientacion == null ? 'Elige hacia dónde apunta la foto' : null;
    errorPrioridad = prioridad == null ? 'Elige la prioridad base' : null;
    errorGeneral = null;
    if (errorNombre != null || errorCodigo != null || errorOrientacion != null || errorPrioridad != null) {
      notifyListeners();
      return false;
    }

    final datos = DatosTipo(
      codigo: esEdicion ? null : codigo.trim(),
      nombre: nombre.trim(),
      orientacion: orientacion!,
      prioridadBase: prioridad!,
    );
    if (esEdicion) return _enviar(() => _tiposRepository.editar(tipo!.id, datos));
    return _enviar(() async {
      final creado = await _tiposRepository.crear(datos);
      // Si el PATCH falla, el tipo ya existe activo: se regresa a E10 y ahí se puede desactivar
      if (creado case Ok(value: final nuevo) when !activoAlCrear) {
        await _tiposRepository.cambiarEstatus(nuevo.id, activo: false);
      }
      return creado;
    });
  }

  /// Desactiva un tipo activo (después de E12a) o reactiva uno inactivo.
  Future<bool> cambiarEstatus() {
    final actual = tipo!;
    return _enviar(() => _tiposRepository.cambiarEstatus(actual.id, activo: !actual.activo));
  }

  Future<bool> _enviar(Future<Result<TipoIncidencia>> Function() peticion) async {
    guardando = true;
    errorGeneral = null;
    notifyListeners();
    final resultado = await peticion();
    guardando = false;
    switch (resultado) {
      case Ok():
        notifyListeners();
        return true;
      // Código repetido: el aviso va debajo del campo Código (PRD §3)
      case Error(error: final Conflicto falla) when !esEdicion:
        errorCodigo = mensajePara(falla);
      case Error(error: final falla):
        errorGeneral = mensajePara(falla);
    }
    notifyListeners();
    return false;
  }
}
