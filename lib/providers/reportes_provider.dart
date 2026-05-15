import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../modelos/reporte.dart';
import '../servicios/reportes_service.dart';
import 'puntos_provider.dart';
import 'notificaciones_provider.dart';

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
  final Ref _ref;
  ReportesNotifier(this._ref) : super(const ReportesState()) {
    cargarReportes();
  }

  Future<void> cargarReportes() async {
    state = state.copyWith(cargando: true, error: null);
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      
      if (DateTime.now().millisecond % 10 == 0) {
        throw 'Error al obtener los reportes del mapa.';
      }

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
      
      // SUMAR PUNTOS (RF-58)
      _ref.read(puntosProvider.notifier).sumarPuntos(100, 'Mascota encontrada');

      // NOTIFICACIÓN (RF-34)
      _ref.read(notificacionesProvider.notifier).agregarNotificacion(
        titulo: '¡Mascota encontrada!',
        mensaje: 'Enhorabuena por encontrar a tu mascota. Has ganado 100 puntos extra.',
        tipo: 'recompensa',
      );

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

final reportesProvider = StateNotifierProvider<ReportesNotifier, ReportesState>(
  (ref) => ReportesNotifier(ref),
);