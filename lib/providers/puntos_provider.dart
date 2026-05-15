import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../servicios/usuario_service.dart';

// Niveles disponibles
enum NivelUsuario { bronce, plata, oro, platino }

extension NivelExtension on NivelUsuario {
  String get nombre {
    switch (this) {
      case NivelUsuario.bronce:  return 'Nivel Bronce';
      case NivelUsuario.plata:   return 'Nivel Plata';
      case NivelUsuario.oro:     return 'Nivel Oro';
      case NivelUsuario.platino: return 'Nivel Platino';
    }
  }

  String get emoji {
    switch (this) {
      case NivelUsuario.bronce:  return '🥉';
      case NivelUsuario.plata:   return '🥈';
      case NivelUsuario.oro:     return '🥇';
      case NivelUsuario.platino: return '💎';
    }
  }

  int get puntosMinimos {
    switch (this) {
      case NivelUsuario.bronce:  return 0;
      case NivelUsuario.plata:   return 500;
      case NivelUsuario.oro:     return 1000;
      case NivelUsuario.platino: return 2000;
    }
  }

  int? get puntosMaximos {
    switch (this) {
      case NivelUsuario.bronce:  return 500;
      case NivelUsuario.plata:   return 1000;
      case NivelUsuario.oro:     return 2000;
      case NivelUsuario.platino: return null;
    }
  }

  NivelUsuario? get siguiente {
    switch (this) {
      case NivelUsuario.bronce:  return NivelUsuario.plata;
      case NivelUsuario.plata:   return NivelUsuario.oro;
      case NivelUsuario.oro:     return NivelUsuario.platino;
      case NivelUsuario.platino: return null;
    }
  }
}

NivelUsuario calcularNivel(int puntos) {
  if (puntos >= 2000) return NivelUsuario.platino;
  if (puntos >= 1000) return NivelUsuario.oro;
  if (puntos >= 500)  return NivelUsuario.plata;
  return NivelUsuario.bronce;
}

double calcularProgreso(int puntos, NivelUsuario nivel) {
  final max = nivel.puntosMaximos;
  if (max == null) return 1.0;
  return (puntos - nivel.puntosMinimos) / (max - nivel.puntosMinimos);
}

// Estado
class PuntosState {
  final int puntos;
  final bool cargando;
  final String? error;

  const PuntosState({
    this.puntos = 0,
    this.cargando = false,
    this.error,
  });

  PuntosState copyWith({int? puntos, bool? cargando, String? error}) {
    return PuntosState(
      puntos: puntos ?? this.puntos,
      cargando: cargando ?? this.cargando,
      error: error,
    );
  }
}

class PuntosNotifier extends StateNotifier<PuntosState> {
  PuntosNotifier() : super(const PuntosState()) {
    cargarPuntos();
  }

  Future<void> cargarPuntos() async {
    state = state.copyWith(cargando: true);
    try {
      final puntos = await UsuarioService.getPuntos();
      state = state.copyWith(puntos: puntos, cargando: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), cargando: false);
    }
  }

  // Para actualizar los puntos localmente tras una acción
  // (cuando llegue el backend, refrescar desde la API en su lugar)
  void sumarPuntos(int cantidad) {
    state = state.copyWith(puntos: state.puntos + cantidad);
  }
}

final puntosProvider = StateNotifierProvider<PuntosNotifier, PuntosState>(
  (ref) => PuntosNotifier(),
);

// Provider del nivel — se recalcula solo cuando cambian los puntos
final nivelProvider = Provider<NivelUsuario>((ref) {
  final puntos = ref.watch(puntosProvider).puntos;
  return calcularNivel(puntos);
});