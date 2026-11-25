import '../../domain/entities/accion_aviso.dart';
import '../../domain/entities/rol.dart';
import '../routing/rutas.dart';

/// A dónde lleva un aviso (de la bandeja o push) según el rol: C2, D2 (D4 si es reapertura) o E4 (design.md).
String rutaDeAviso(Rol rol, int incidenciaId, AccionAviso accion) => switch (rol) {
      Rol.ciudadano => Rutas.detalleCiudadano(incidenciaId),
      // TODO(HU-23): con D4 listo, ir ahí cuando accion == AccionAviso.reapertura
      Rol.operativo => Rutas.detalleOperativo(incidenciaId),
      Rol.admin => Rutas.detalleAdmin(incidenciaId),
      Rol.desconocido => Rutas.login,
    };
