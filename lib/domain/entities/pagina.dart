/// Una página de resultados (`?page=0&size=20`).
class Pagina<T> {
  const Pagina({required this.contenido, required this.numero, required this.totalPaginas});

  final List<T> contenido;

  /// Empieza en 0.
  final int numero;
  final int totalPaginas;

  bool get esUltima => numero + 1 >= totalPaginas;
}
