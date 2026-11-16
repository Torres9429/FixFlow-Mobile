import '../../../core/result.dart';
import '../../../domain/errors/falla_red.dart';
import '../../../domain/entities/estado_incidencia.dart';
import '../../../domain/entities/incidencia_resumen.dart';
import '../../../domain/entities/indicadores.dart';
import '../../../domain/entities/operativo.dart';
import '../../../domain/entities/pagina.dart';
import '../../../domain/entities/prioridad.dart';
import '../../../domain/repositories/admin_repository.dart';
import 'datos_demo.dart';

/// Panel del admin en el modo mock, con las cifras de design.md §9.
class FakeAdminRepository implements AdminRepository {
  final _operativos = <Operativo>[
    const Operativo(
      id: 1,
      nombre: 'Roberto',
      apellidos: 'Mendoza',
      correo: 'roberto.mendoza@municipio.gob.mx',
      activo: true,
      cargaActual: 2,
    ),
    const Operativo(
      id: 2,
      nombre: 'Jaime',
      apellidos: 'Torres',
      correo: 'jaime.torres@municipio.gob.mx',
      activo: true,
      cargaActual: 1,
    ),
    const Operativo(
      id: 3,
      nombre: 'Sara',
      apellidos: 'Valenzuela',
      correo: 'sara.valenzuela@municipio.gob.mx',
      activo: true,
      cargaActual: 3,
    ),
    const Operativo(
      id: 4,
      nombre: 'Miguel Ángel',
      apellidos: 'Solís',
      correo: 'miguel.solis@municipio.gob.mx',
      activo: false,
      cargaActual: 0,
    ),
  ];

  @override
  Future<Result<Indicadores>> indicadores() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return const Result.ok(
      Indicadores(
        registradas: 128,
        pendientes: 23,
        enAtencion: 8,
        atendidas: 97,
        porPrioridad: {
          Prioridad.alta: 12,
          Prioridad.media: 58,
          Prioridad.baja: 58,
        },
        resolucionPromedioHoras: 77,
        resolucionMaxHoras: 312,
      ),
    );
  }

  @override
  Future<Result<Pagina<IncidenciaResumen>>> incidencias({
    EstadoIncidencia? estado,
    Prioridad? prioridad,
    int pagina = 0,
    int tamano = 20,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final filtradas = DatosDemo.municipio
        .where(
          (i) =>
              (estado == null || i.estado == estado) &&
              (prioridad == null || i.prioridad == prioridad),
        )
        .take(tamano)
        .toList();
    return Result.ok(Pagina(contenido: filtradas, numero: 0, totalPaginas: 1));
  }

  @override
  Future<Result<List<Operativo>>> operativosDisponibles() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return Result.ok(
      List.unmodifiable(_operativos.where((operativo) => operativo.activo)),
    );
  }

  @override
  Future<Result<List<Operativo>>> listarOperativos() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return Result.ok(List.unmodifiable(_operativos));
  }

  @override
  Future<Result<void>> crearOperativo({
    required String nombre,
    required String apellidos,
    required String correo,
    required String passwordTemporal,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (_operativos.any(
      (operativo) =>
          operativo.correo.toLowerCase() == correo.trim().toLowerCase(),
    )) {
      return const Result.error(Conflicto('El correo ya está registrado'));
    }
    _operativos.add(
      Operativo(
        id:
            _operativos.fold(
              0,
              (maxId, operativo) => operativo.id > maxId ? operativo.id : maxId,
            ) +
            1,
        nombre: nombre.trim(),
        apellidos: apellidos.trim(),
        correo: correo.trim().toLowerCase(),
        activo: true,
        cargaActual: 0,
      ),
    );
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> cambiarEstatusOperativo(
    int id, {
    required bool activo,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final index = _operativos.indexWhere((operativo) => operativo.id == id);
    if (index == -1) return const Result.error(NoEncontrado());
    final operativo = _operativos[index];
    _operativos[index] = Operativo(
      id: operativo.id,
      nombre: operativo.nombre,
      apellidos: operativo.apellidos,
      correo: operativo.correo,
      activo: activo,
      cargaActual: operativo.cargaActual,
    );
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> asignarIncidencia(
    int incidenciaId,
    int operativoId,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return const Result.ok(null);
  }
}
