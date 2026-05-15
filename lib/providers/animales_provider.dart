import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../modelos/animal.dart';
import '../servicios/animales_service.dart';
import 'notificaciones_provider.dart';

class AnimalesState {
  final List<Animal> animales;
  final bool cargando;
  final String? error;

  const AnimalesState({
    this.animales = const [],
    this.cargando = false,
    this.error,
  });

  AnimalesState copyWith({
    List<Animal>? animales,
    bool? cargando,
    String? error,
  }) {
    return AnimalesState(
      animales: animales ?? this.animales,
      cargando: cargando ?? this.cargando,
      error: error,
    );
  }
}

class AnimalesNotifier extends StateNotifier<AnimalesState> {
  final Ref _ref;

  AnimalesNotifier(this._ref) : super(const AnimalesState()) {
    cargarAnimales();
  }

  Future<void> cargarAnimales() async {
    state = state.copyWith(cargando: true, error: null);
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Simulación de error aleatorio (1 de cada 10)
      if (DateTime.now().millisecond % 10 == 0) {
        throw 'Error de conexión con el servidor de PetSafe.';
      }

      final animales = await AnimalesService.getAnimales();
      state = state.copyWith(animales: animales, cargando: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), cargando: false);
    }
  }

  Future<void> recargar() => cargarAnimales();

  Future<void> agregarAnimal(Animal animal) async {
    state = state.copyWith(cargando: true);
    try {
      await AnimalesService.crearAnimal(animal);
      await cargarAnimales();
    } catch (e) {
      state = state.copyWith(error: e.toString(), cargando: false);
    }
  }

  Future<void> editarAnimal(Animal animal) async {
    state = state.copyWith(cargando: true);
    try {
      await AnimalesService.actualizarAnimal(animal);
      await cargarAnimales();
    } catch (e) {
      state = state.copyWith(error: e.toString(), cargando: false);
    }
  }

  Future<void> eliminarAnimal(String id) async {
    state = state.copyWith(cargando: true);
    try {
      await AnimalesService.eliminarAnimal(id);
      await cargarAnimales();
    } catch (e) {
      state = state.copyWith(error: e.toString(), cargando: false);
    }
  }

  Future<void> darDeBaja(String id, String motivo) async {
    state = state.copyWith(cargando: true);
    try {
      final animal = state.animales.firstWhere((a) => a.id == id);
      final actualizado = animal.copyWith(
        estado: motivo,
        disponible: false,
      );
      await AnimalesService.actualizarAnimal(actualizado);

      // NOTIFICACIÓN DE SISTEMA (RF-34)
      _ref.read(notificacionesProvider.notifier).agregarNotificacion(
        titulo: 'Registro Actualizado',
        mensaje: '${animal.nombre} ha sido dado de baja por: $motivo.',
        tipo: 'sistema',
      );

      await cargarAnimales();
    } catch (e) {
      state = state.copyWith(error: e.toString(), cargando: false);
    }
  }
}

final animalesProvider = StateNotifierProvider<AnimalesNotifier, AnimalesState>(
  (ref) => AnimalesNotifier(ref),
);