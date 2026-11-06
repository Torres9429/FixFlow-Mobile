const _meses = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];

String _dosDigitos(int n) => n.toString().padLeft(2, '0');

DateTime _soloDia(DateTime f) => DateTime(f.year, f.month, f.day);

/// Fecha corta de las tarjetas, en 24 h (design.md §8): «hoy, 11:30», «ayer, 18:05» o «28 oct 2026, 09:15».
String formatearFechaCorta(DateTime fecha, {DateTime? ahora}) {
  final hora = '${_dosDigitos(fecha.hour)}:${_dosDigitos(fecha.minute)}';
  final dias = _soloDia(ahora ?? DateTime.now()).difference(_soloDia(fecha)).inDays;

  if (dias == 0) return 'hoy, $hora';
  if (dias == 1) return 'ayer, $hora';
  return formatearFechaLarga(fecha);
}

/// Fecha completa del encabezado y las fotos del detalle: «28 oct 2026, 09:15».
String formatearFechaLarga(DateTime fecha) =>
    '${fecha.day} ${_meses[fecha.month - 1]} ${fecha.year}, ${_dosDigitos(fecha.hour)}:${_dosDigitos(fecha.minute)}';

/// Fecha del historial (design.md §7): «hoy, 14:00», «ayer, 14:00» o «29 oct, 14:00».
String formatearFechaSinAnio(DateTime fecha, {DateTime? ahora}) {
  final corta = formatearFechaCorta(fecha, ahora: ahora);
  if (corta.startsWith('hoy') || corta.startsWith('ayer')) return corta;
  return '${fecha.day} ${_meses[fecha.month - 1]}, ${_dosDigitos(fecha.hour)}:${_dosDigitos(fecha.minute)}';
}
