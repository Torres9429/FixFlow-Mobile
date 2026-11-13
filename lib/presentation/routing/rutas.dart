abstract final class Rutas {
  static const login = '/login';
  static const registro = '/registro';

  // Ciudadano: pestañas Mis reportes · Reportar · Avisos
  static const homeCiudadano = '/ciudadano/reportes'; // B1
  static const avisosCiudadano = '/ciudadano/avisos'; // C1
  static const nuevoReporte = '/reporte/nuevo'; // B2
  static const reporteEnviado = '/reporte/enviado'; // B5

  // Operativo: pestañas Asignadas · Mapa · Avisos
  static const homeOperativo = '/operativo/asignadas'; // D1
  static const mapaOperativo = '/operativo/mapa'; // D5
  static const avisosOperativo = '/operativo/avisos'; // D6

  // Admin: pestañas Inicio · Personal · Incidencias · Perfil, y la campana
  static const homeAdmin = '/admin/inicio'; // E1
  static const personal = '/admin/personal'; // E8
  static const incidenciasAdmin = '/admin/incidencias'; // E2
  static const perfilAdmin = '/admin/perfil'; // A3 como pestaña
  static const avisosAdmin = '/admin/avisos'; // E7

  // Perfil del ciudadano y del operativo, desde el botón de la barra superior
  static const perfil = '/perfil'; // A3
  static const editarDatos = '/perfil/datos';
  static const cambiarPassword = '/perfil/password';

  // Detalle de la incidencia, dentro de la pestaña de donde se abre
  static String detalleCiudadano(int id) => '$homeCiudadano/$id'; // C2
  static String detalleOperativo(int id) => '$homeOperativo/$id'; // D2
  static String detalleAdmin(int id) => '$homeAdmin/$id'; // E4
  static String asignarAdmin(int id) => '${detalleAdmin(id)}/asignar'; // E5, desde el detalle
}
