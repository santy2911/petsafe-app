import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../modelos/animal.dart';
import '../servicios/animales_service.dart';

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
  AnimalesNotifier() : super(const AnimalesState()) {
    cargarAnimales();
  }

  Future<void> cargarAnimales() async {
    state = state.copyWith(cargando: true);
    try {
      final animales = await AnimalesService.getAnimales();
      state = state.copyWith(animales: animales, cargando: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), cargando: false);
    }
  }

  Future<void> recargar() => cargarAnimales();
}

final animalesProvider =
    StateNotifierProvider<AnimalesNotifier, AnimalesState>(
  (ref) => AnimalesNotifier(),
);