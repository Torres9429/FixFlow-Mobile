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


String? Function(String?) validarPasswordNueva(String Function() obtenerActual) {
  return (String? valor) {
    final error = validarPassword(valor);
    if (error != null) return error;
    if (valor == obtenerActual()) return 'Debe ser distinta de la actual';
    return null;
  };
}

typedef RequisitosPassword = ({bool largo, bool letrasYNumeros, bool distinta});

RequisitosPassword requisitosPassword(String nueva, String actual) => (
  largo: nueva.length >= 8,
  letrasYNumeros: RegExp(r'[a-zA-Z]').hasMatch(nueva) && RegExp(r'[0-9]').hasMatch(nueva),
  distinta: nueva.isNotEmpty && nueva != actual,
);

/// Nombre de un tipo de incidencia: obligatorio y hasta 80 caracteres (HU-26).
String? validarNombreTipo(String? valor) {
  if (valor == null || valor.trim().isEmpty) return 'El nombre es obligatorio';
  if (valor.trim().length > 80) return 'Máximo 80 caracteres';
  return null;
}

/// Código de un tipo: opcional; si se escribe, de 2 a 30 mayúsculas, números o `_` (RN-07).
String? validarCodigoTipo(String? valor) {
  if (valor == null || valor.trim().isEmpty) return null;
  if (!RegExp(r'^[A-Z0-9_]{2,30}$').hasMatch(valor.trim())) {
    return 'Solo mayúsculas, números y guion bajo (2 a 30)';
  }
  return null;
}

/// Descripción de la solución: obligatoria y hasta 500 caracteres (HU-16 / RF-18).
String? validarDescripcionSolucion(String? valor) {
  if (valor == null || valor.trim().isEmpty) return 'Campo obligatorio';
  if (valor.trim().length > 500) return 'Máximo 500 caracteres';
  return null;
}

/// Justificación de la reapertura: obligatoria, de 10 a 500 caracteres (HU-23 / RN-17).
String? validarJustificacionReapertura(String? valor) {
  final texto = valor?.trim() ?? '';
  if (texto.isEmpty) return 'Campo obligatorio';
  if (texto.length < 10) return 'Mínimo 10 caracteres';
  if (texto.length > 500) return 'Máximo 500 caracteres';
  return null;
}
