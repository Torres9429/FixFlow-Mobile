String? validarObligatorio(String? valor) =>
    (valor == null || valor.trim().isEmpty) ? 'Campo obligatorio' : null;

String? validarCorreo(String? valor) {
  if (valor == null || valor.trim().isEmpty) return 'Campo obligatorio';
  // Patrón básico: algo@algo.algo
  final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!regex.hasMatch(valor.trim())) return 'Correo no válido';
  return null;
}

String? validarPassword(String? valor) {
  if (valor == null || valor.trim().isEmpty) return 'Campo obligatorio';
  if (valor.length < 8) return 'Mínimo 8 caracteres';
  if (!RegExp(r'[a-zA-Z]').hasMatch(valor)) return 'Debe incluir letras';
  if (!RegExp(r'[0-9]').hasMatch(valor)) return 'Debe incluir números';
  return null;
}

/// Genera un validador que compara contra otro campo.
String? Function(String?) validarConfirmarPassword(String Function() obtenerPassword) {
  return (String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Campo obligatorio';
    if (valor != obtenerPassword()) return 'Las contraseñas no coinciden';
    return null;
  };
}

