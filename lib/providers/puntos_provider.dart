import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../servicios/usuario_service.dart';

// Niveles disponibles actualizados según solicitud USER
enum NivelUsuario { bronce, plata, oro }

extension NivelExtension on NivelUsuario {
  String get nombre {
    switch (this) {
      case NivelUsuario.bronce: return 'Bronce';
      case NivelUsuario.plata:  return 'Plata';
      case NivelUsuario.oro:    return 'Oro';
    }
  }

  String get emoji {
    switch (this) {
      case NivelUsuario.bronce: return '🥉';
      case NivelUsuario.plata:  return '🥈';
      case NivelUsuario.oro:    return '🥇';
    }
  }

  int get puntosMinimos {
    switch (this) {
      case NivelUsuario.bronce: return 0;
      case NivelUsuario.plata:  return 101;
      case NivelUsuario.oro:    return 301;
    }
  }

  int? get puntosMaximos {
    switch (this) {
      case NivelUsuario.bronce: return 100;
      case NivelUsuario.plata:  return 300;
      case NivelUsuario.oro:    return null;
    }
  }

  NivelUsuario? get siguiente {
    switch (this) {
      case NivelUsuario.bronce: return NivelUsuario.plata;
      case NivelUsuario.plata:  return NivelUsuario.oro;
      case NivelUsuario.oro:    return null;
    }
  }
}

NivelUsuario calcularNivel(int puntos) {
  if (puntos >= 301) return NivelUsuario.oro;
  if (puntos >= 101) return NivelUsuario.plata;
  return NivelUsuario.bronce;
}

double calcularProgreso(int puntos, NivelUsuario nivel) {
  final max = nivel.puntosMaximos;
  if (max == null) return 1.0;
  final min = nivel.puntosMinimos;
  // Ajuste para el primer nivel que empieza en 0
  final baseMin = (nivel == NivelUsuario.bronce) ? 0 : min;
  return ((puntos - baseMin) / (max - baseMin)).clamp(0.0, 1.0);
}

class MovimientoPuntos {
  final String accion;
  final int puntos;
  final DateTime fecha;

  MovimientoPuntos({required this.accion, required this.puntos, required this.fecha});
}

// Estado
class PuntosState {
  final int puntos;
  final List<MovimientoPuntos> historial;
  final bool cargando;
  final String? error;

  const PuntosState({
    this.puntos = 0,
    this.historial = const [],
    this.cargando = false,
    this.error,
  });

  PuntosState copyWith({int? puntos, List<MovimientoPuntos>? historial, bool? cargando, String? error}) {
    return PuntosState(
      puntos: puntos ?? this.puntos,
      historial: historial ?? this.historial,
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
      // Mocks de historial inicial más variados
      final mockHistorial = [
        MovimientoPuntos(accion: 'Registro inicial', puntos: 50, fecha: DateTime.now().subtract(const Duration(days: 10))),
        MovimientoPuntos(accion: 'Completar perfil', puntos: 25, fecha: DateTime.now().subtract(const Duration(days: 8))),
        MovimientoPuntos(accion: 'Reporte mascota perdida', puntos: 50, fecha: DateTime.now().subtract(const Duration(days: 2))),
      ];
      state = state.copyWith(puntos: puntos, historial: mockHistorial, cargando: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), cargando: false);
    }
  }

  void sumarPuntos(int cantidad, String motivo) {
    final nuevoMovimiento = MovimientoPuntos(
      accion: motivo,
      puntos: cantidad,
      fecha: DateTime.now(),
    );
    state = state.copyWith(
      puntos: state.puntos + cantidad,
      historial: [nuevoMovimiento, ...state.historial],
    );
  }
}

final puntosProvider = StateNotifierProvider<PuntosNotifier, PuntosState>(
  (ref) => PuntosNotifier(),
);

final nivelProvider = Provider<NivelUsuario>((ref) {
  final puntos = ref.watch(puntosProvider).puntos;
  return calcularNivel(puntos);
});