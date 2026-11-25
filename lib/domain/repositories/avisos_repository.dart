import '../../core/result.dart';
import '../entities/aviso.dart';
import '../entities/pagina.dart';

/// Bandeja de avisos del usuario con sesión (HU-12, RN-18). Sirve igual a los 3 roles.
abstract interface class AvisosRepository {
  /// `GET /notificaciones`, más recientes primero.
  Future<Result<Pagina<Aviso>>> avisos({int pagina = 0});

  /// `GET /notificaciones/no-leidas`: para el punto naranja.
  Future<Result<int>> noLeidos();

  /// `PATCH /notificaciones/{id}/leida`.
  Future<Result<void>> marcarLeido(int id);

  /// `PATCH /notificaciones/leidas`.
  Future<Result<void>> marcarTodosLeidos();
}
