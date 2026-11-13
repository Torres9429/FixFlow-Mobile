import '../../domain/entities/rol.dart';

String nombreRol(Rol rol) => switch (rol) {
  Rol.ciudadano => 'Ciudadano',
  Rol.operativo => 'Personal operativo',
  Rol.admin => 'Administrador',
  Rol.desconocido => 'Usuario',
};
