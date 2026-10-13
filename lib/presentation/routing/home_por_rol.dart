import '../../domain/entities/rol.dart';
import 'rutas.dart';

/// Ruta de la home de cada rol (HU-02, CA-5). Un rol desconocido regresa al login.
String rutaHomePorRol(Rol rol) => switch (rol) {
      Rol.ciudadano => Rutas.homeCiudadano,
      Rol.operativo => Rutas.homeOperativo,
      Rol.admin => Rutas.homeAdmin,
      Rol.desconocido => Rutas.login,
    };
