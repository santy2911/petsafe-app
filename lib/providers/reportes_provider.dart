import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../modelos/reporte.dart';
import '../servicios/reportes_service.dart';

class ReportesState {
  final List<Reporte> reportes;
  final bool cargando;
  final String? error;

  const ReportesState({
    this.reportes = const [],
    this.cargando = false,
    this.error,
  });

  ReportesState copyWith({
    List<Reporte>? reportes,
    bool? cargando,
    String? error,
  }) {
    return ReportesState(
      reportes: reportes ?? this.reportes,
      cargando: cargando ?? this.cargando,
      error: error,
    );
  }
}

class ReportesNotifier extends StateNotifier<ReportesState> {
  ReportesNotifier() : super(const ReportesState()) {
    cargarReportes();
  }

  Future<void> cargarReportes() async {
    state = state.copyWith(cargando: true);
    try {
      final reportes = await ReportesService.getReportes();
      state = state.copyWith(reportes: reportes, cargando: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), cargando: false);
    }
  }

  Future<void> agregar(Reporte reporte) async {
    try {
      await ReportesService.crearReporte(reporte);
      state = state.copyWith(reportes: [reporte, ...state.reportes]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> marcarEncontrado(String id) async {
    try {
      await ReportesService.marcarEncontrado(id);
      state = state.copyWith(
        reportes: [
          for (final r in state.reportes)
            if (r.id == id) r.copyWith(encontrado: true) else r,
        ],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> eliminar(String id) async {
    try {
      // Cuando llegue el backend añadir llamada a ReportesService.eliminarReporte(id)
      state = state.copyWith(
        reportes: state.reportes.where((r) => r.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final reportesProvider =
    StateNotifierProvider<ReportesNotifier, ReportesState>(
  (ref) => ReportesNotifier(),
);