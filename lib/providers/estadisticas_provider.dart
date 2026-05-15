import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../servicios/usuario_service.dart';

class EstadisticasState {
  final int adopciones;
  final int reportes;
  final bool cargando;

  const EstadisticasState({
    this.adopciones = 0,
    this.reportes = 0,
    this.cargando = false,
  });

  EstadisticasState copyWith({
    int? adopciones,
    int? reportes,
    bool? cargando,
  }) {
    return EstadisticasState(
      adopciones: adopciones ?? this.adopciones,
      reportes: reportes ?? this.reportes,
      cargando: cargando ?? this.cargando,
    );
  }
}

class EstadisticasNotifier extends StateNotifier<EstadisticasState> {
  EstadisticasNotifier() : super(const EstadisticasState()) {
    cargarEstadisticas();
  }

  Future<void> cargarEstadisticas() async {
    state = state.copyWith(cargando: true);
    try {
      final stats = await UsuarioService.getEstadisticas();
      state = state.copyWith(
        adopciones: stats['adopciones'] ?? 0,
        reportes: stats['reportes'] ?? 0,
        cargando: false,
      );
    } catch (e) {
      // Si falla, se queda en 0 sin romper la pantalla
      state = state.copyWith(cargando: false);
    }
  }

  // Para incrementar localmente sin esperar al servidor
  // (útil para feedback inmediato en la UI)
  void sumarAdopcion() {
    state = state.copyWith(adopciones: state.adopciones + 1);
  }

  void sumarReporte() {
    state = state.copyWith(reportes: state.reportes + 1);
  }
}

final estadisticasProvider =
    StateNotifierProvider<EstadisticasNotifier, EstadisticasState>(
  (ref) => EstadisticasNotifier(),
);