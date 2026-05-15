import '../modelos/animal.dart';
import 'api_service.dart';
import 'auth_service.dart';

class FavoritosService {

  // Obtener los animales favoritos del usuario
  static Future<List<Animal>> getFavoritos() async {
    // MOCK temporal — eliminar cuando llegue el backend
    await Future.delayed(const Duration(milliseconds: 300));
    return [];

    // Cuando llegue el backend, descomenta esto y borra el mock:
    // final data = await ApiService.get(
    //   '/favoritos',
    //   token: AuthService.token,
    // );
    // return (data as List).map((e) => Animal.fromJson(e)).toList();
  }

  // Añadir un animal a favoritos
  static Future<void> agregarFavorito(String idAnimal) async {
    // MOCK temporal — eliminar cuando llegue el backend
    await Future.delayed(const Duration(milliseconds: 200));

    // Cuando llegue el backend, descomenta esto y borra el mock:
    // await ApiService.post(
    //   '/favoritos',
    //   {'idAnimal': idAnimal},
    //   token: AuthService.token,
    // );
  }

  // Eliminar un animal de favoritos
  static Future<void> eliminarFavorito(String idAnimal) async {
    // MOCK temporal — eliminar cuando llegue el backend
    await Future.delayed(const Duration(milliseconds: 200));

    // Cuando llegue el backend, descomenta esto y borra el mock:
    // await ApiService.delete(
    //   '/favoritos/$idAnimal',
    //   token: AuthService.token,
    // );
  }
}