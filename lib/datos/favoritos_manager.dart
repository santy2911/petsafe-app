import '../modelos/animal.dart';

// Singleton en memoria para los animales guardados como favoritos.
// En produccion reemplazar por Riverpod + Hive o SharedPreferences.
class FavoritosManager {
  static final FavoritosManager _instancia = FavoritosManager._();
  FavoritosManager._();
  factory FavoritosManager() => _instancia;

  final List<Animal> _favoritos = [];

  List<Animal> get favoritos => List.unmodifiable(_favoritos);

  bool esFavorito(String id) => _favoritos.any((a) => a.id == id);

  // Devuelve true si lo agrega, false si lo elimina
  bool toggleFavorito(Animal animal) {
    if (esFavorito(animal.id)) {
      _favoritos.removeWhere((a) => a.id == animal.id);
      return false;
    } else {
      _favoritos.add(animal);
      return true;
    }
  }
}