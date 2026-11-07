/// Desde qué rol se abre el detalle: C2 (ciudadano), D2 (operativo) o E4 (admin).
enum VistaDetalle {
  ciudadano('Detalle del reporte'),
  operativo('Detalle de la incidencia'),
  admin('Detalle de la incidencia');

  const VistaDetalle(this.titulo);

  final String titulo;
}
