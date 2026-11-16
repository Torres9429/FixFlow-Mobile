import 'package:flutter/material.dart';

import '../core/widgets/hoja_confirmacion.dart';

/// A3c: confirmación antes de cerrar sesión.
Future<bool> confirmarCierreSesion(BuildContext context) => confirmarAccion(
  context,
  titulo: '¿Cerrar sesión?',
  mensaje: 'Tendrás que escribir tu correo y contraseña para volver a entrar.',
  accion: 'Cerrar sesión',
  destructiva: true,
  claveConfirmar: const Key('confirmar_cerrar_sesion'),
  claveCancelar: const Key('cancelar_cerrar_sesion'),
);
