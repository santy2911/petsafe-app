import '../modelos/animal.dart';
import '../datos/animales_mock.dart';
import 'api_service.dart';
import '../servicios/auth_service.dart';

class AnimalesService {

  static Future<List<Animal>> getAnimales() async {
    // Cuando llegue el backend, descomenta esto y borra el mock:
    // final data = await ApiService.get('/animales', token: AuthService.token);
    // return (data as List).map((e) => Animal.fromJson(e)).toList();

    // MOCK temporal
    await Future.delayed(const Duration(milliseconds: 300));
    return animalesMock;
  }

  static Future<Animal> getAnimalPorId(String id) async {
    // Cuando llegue el backend, descomenta esto y borra el mock:
    // final data = await ApiService.get('/animales/$id', token: AuthService.token);
    // return Animal.fromJson(data);

    // MOCK temporal
    await Future.delayed(const Duration(milliseconds: 300));
    return animalesMock.firstWhere((a) => a.id == id);
  }

  static Future<void> crearAnimal(Animal animal) async {
    // Mock: Simular guardado
    await Future.delayed(const Duration(milliseconds: 500));
    animalesMock.add(animal);
  }

  static Future<void> actualizarAnimal(Animal animal) async {
    // Mock: Simular actualizacion
    await Future.delayed(const Duration(milliseconds: 500));
    final index = animalesMock.indexWhere((a) => a.id == animal.id);
    if (index != -1) {
      animalesMock[index] = animal;
    }
  }

  static Future<void> eliminarAnimal(String id) async {
    // Mock: Simular eliminacion
    await Future.delayed(const Duration(milliseconds: 500));
    animalesMock.removeWhere((a) => a.id == id);
  }
}