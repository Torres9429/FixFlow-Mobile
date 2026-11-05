import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../routing/rutas.dart';

/// Estructura del ciudadano: Mis reportes · Reportar (botón naranja al centro) · Avisos.
class CiudadanoShell extends StatelessWidget {
  const CiudadanoShell({super.key, required this.shell, this.avisosNoLeidos = false});

  final StatefulNavigationShell shell;
  final bool avisosNoLeidos;

  static const _alturaBarra = AppTheme.alturaBarraInferior;

  /// Icono + espacio + texto de una pestaña normal; va centrado en la barra.
  static const _altoPestana = _icono + _espacio + _altoTexto;

  /// Lo que el botón Reportar sobresale, calculado para que «Reportar» quede a la altura de las otras etiquetas.
  static const _sobresale = _diametroReportar + _espacio - ((_alturaBarra - _altoPestana) / 2 + _icono + _espacio);

  void _irA(int rama) => shell.goBranch(rama, initialLocation: rama == shell.currentIndex);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      // La zona de toque incluye la parte del botón que sobresale; solo la parte de abajo es la barra blanca
      bottomNavigationBar: ColoredBox(
        color: AppColors.surface,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: _alturaBarra + _sobresale,
            child: Stack(
              children: [
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: _alturaBarra,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: AppColors.surface, boxShadow: AppTheme.sombraBarraInferior),
                  ),
                ),
                Positioned.fill(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: _alturaBarra,
                          child: _Pestana(
                            key: const Key('tab_mis_reportes'),
                            icono: Icons.assignment_outlined,
                            texto: 'Mis reportes',
                            activa: shell.currentIndex == 0,
                            onTap: () => _irA(0),
                          ),
                        ),
                      ),
                      Expanded(child: _BotonReportar(onTap: () => context.push(Rutas.nuevoReporte))),
                      Expanded(
                        child: SizedBox(
                          height: _alturaBarra,
                          child: _Pestana(
                            key: const Key('tab_avisos'),
                            icono: Icons.notifications_outlined,
                            texto: 'Avisos',
                            activa: shell.currentIndex == 1,
                            conPunto: avisosNoLeidos,
                            onTap: () => _irA(1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Medidas de la barra del ciudadano
const _icono = 24.0;
const _espacio = 4.0;
const _altoTexto = 16.0;
const _diametroReportar = 56.0;

TextStyle? _estiloEtiqueta(BuildContext context, {required FontWeight peso, required Color color}) =>
    Theme.of(context).textTheme.labelMedium
        ?.copyWith(fontSize: 12, height: _altoTexto / 12, fontWeight: peso, color: color);

class _Pestana extends StatelessWidget {
  const _Pestana({
    super.key,
    required this.icono,
    required this.texto,
    required this.activa,
    required this.onTap,
    this.conPunto = false,
  });

  final IconData icono;
  final String texto;
  final bool activa;
  final VoidCallback onTap;
  final bool conPunto;

  @override
  Widget build(BuildContext context) {
    final color = activa ? AppColors.primary : AppColors.textMuted;

    return Semantics(
      selected: activa,
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icono, size: _icono, color: color),
                if (conPunto)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: _espacio),
            Text(
              texto,
              style: _estiloEtiqueta(context, peso: activa ? FontWeight.w600 : FontWeight.w500, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botón flotante: círculo naranja de 56 con «+» que sobresale de la barra, con sombra naranja y la etiqueta debajo.
class _BotonReportar extends StatelessWidget {
  const _BotonReportar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: const BoxDecoration(shape: BoxShape.circle, boxShadow: AppTheme.sombraReportar),
          child: Material(
            color: AppColors.accent,
            shape: const CircleBorder(),
            child: InkWell(
              key: const Key('boton_reportar'),
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: const SizedBox.square(
                dimension: _diametroReportar,
                child: Icon(Icons.add, size: 28, color: Colors.white, semanticLabel: 'Nuevo reporte'),
              ),
            ),
          ),
        ),
        const SizedBox(height: _espacio),
        Text(
          'Reportar',
          style: _estiloEtiqueta(context, peso: FontWeight.w600, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
