import 'package:flutter/material.dart';

/// Lista con encabezado, deslizar para recargar y siguiente página al llegar al final.
/// La comparten B1, D1 y E2.
class ListaIncidencias extends StatelessWidget {
  const ListaIncidencias({
    super.key,
    required this.encabezado,
    required this.contenido,
    required this.onRecargar,
    this.onFinal,
  });

  /// Saludo, chips o lo que va arriba de las tarjetas.
  final List<Widget> encabezado;

  /// Tarjetas, esqueleto o estado vacío.
  final List<Widget> contenido;
  final Future<void> Function() onRecargar;
  final VoidCallback? onFinal;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRecargar,
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (onFinal != null && n.metrics.extentAfter < 300) onFinal!();
          return false;
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          children: [...encabezado, ...contenido],
        ),
      ),
    );
  }
}

/// Tarjetas con el margen lateral de 20 y 12 entre ellas.
List<Widget> conSeparacion(Iterable<Widget> tarjetas) => [
  for (final (i, tarjeta) in tarjetas.indexed)
    Padding(padding: EdgeInsets.fromLTRB(20, i == 0 ? 0 : 12, 20, 0), child: tarjeta),
];
