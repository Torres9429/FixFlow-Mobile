import 'package:flutter/material.dart';

/// Paleta "Señal naranja" (Propuesta 2).
///
/// Regla del proyecto: los colores solo se toman de aquí, nunca con
/// `Color(0x...)` sueltos dentro de las pantallas.
abstract final class AppColors {
  // Marca
  static const primary = Color(0xFF0B3C5D); // barra superior, botones, enlaces
  static const primaryDark = Color(0xFF072A42); // enlace presionado
  static const primaryContainer = Color(0xFFE1ECF4); // fondo de íconos en tarjetas
  static const accent = Color(0xFFFF5A1F); // botón Reportar, contador de notificaciones
  static const onAccent = Color(0xFF1B1F24); // texto sobre el acento

  // Superficies
  static const background = Color(0xFFF6F4F1); // fondo de las pantallas
  static const surface = Color(0xFFFFFFFF); // tarjetas y formularios

  // Texto
  static const textPrimary = Color(0xFF1B1F24);
  static const textSecondary = Color(0xFF3D4652);
  static const textMuted = Color(0xFF59616C); // ayudas y fechas
  static const placeholder = Color(0xFF6B7380);

  // Bordes
  static const border = Color(0xFFC2C8D1);

  static const error = Color(0xFFB3261E);

  // Prioridad (fondo, texto)
  static const prioridadAltaBg = Color(0xFFFDE4E1);
  static const prioridadAlta = Color(0xFFB3261E);
  static const prioridadMediaBg = Color(0xFFFFEFD1);
  static const prioridadMedia = Color(0xFF8A5300);
  static const prioridadBajaBg = Color(0xFFE6ECEF);
  static const prioridadBaja = Color(0xFF45555E);

  // Estado de la incidencia (fondo, texto)
  static const pendienteBg = Color(0xFFECEDEF);
  static const pendiente = Color(0xFF4A5059);
  static const asignadaBg = Color(0xFFE7E9FB);
  static const asignada = Color(0xFF3341A6);
  static const enProcesoBg = Color(0xFFE0F0FB);
  static const enProceso = Color(0xFF0B5F94);
  static const resueltaBg = Color(0xFFE2F3E5);
  static const resuelta = Color(0xFF1E6B2C);
  static const reabiertaBg = Color(0xFFF3E5F7);
  static const reabierta = Color(0xFF7B1F96);
  static const cerradaBg = Color(0xFFE3E7EA);
  static const cerrada = Color(0xFF37474F);
}
