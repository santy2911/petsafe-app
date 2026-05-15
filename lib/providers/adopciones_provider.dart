import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../modelos/solicitud_adopcion.dart';
import '../servicios/adopciones_service.dart';

// Estado
class AdopcionesState {
  final List<SolicitudAdopcion> solicitudes;
  final bool cargando;
  final String? error;

  const AdopcionesState({
    this.solicitudes = const [],
    this.cargando = false,
    this.error,
  });

  AdopcionesState copyWith({
    List<SolicitudAdopcion>? solicitudes,
    bool? cargando,
    String? error,
  }) {
    return AdopcionesState(
      solicitudes: solicitudes ?? this.solicitudes,
      cargando: cargando ?? this.cargando,
      error: error,
    );
  }
}

// Notifier
class AdopcionesNotifier extends StateNotifier<AdopcionesState> {
  AdopcionesNotifier() : super(const AdopcionesState()) {
    cargarSolicitudes();
  }

  // Carga las solicitudes del usuario desde el backend
  Future<void> cargarSolicitudes() async {
    state = state.copyWith(cargando: true);
    try {
      final solicitudes = await AdopcionesService.getMisSolicitudes();
      state = state.copyWith(solicitudes: solicitudes, cargando: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), cargando: false);
    }
  }

  // Enviar una nueva solicitud de adopción
  Future<bool> crearSolicitud({
    required String idAnimal,
    required String comentarios,
  }) async {
    state = state.copyWith(cargando: true);
    try {
      final nueva = await AdopcionesService.crearSolicitud(
        idAnimal: idAnimal,
        comentarios: comentarios,
      );
      state = state.copyWith(
        solicitudes: [nueva, ...state.solicitudes],
        cargando: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString(), cargando: false);
      return false;
    }
  }

  // Cancelar una solicitud
  Future<void> cancelarSolicitud(String idSolicitud) async {
    try {
      await AdopcionesService.cancelarSolicitud(idSolicitud);
      state = state.copyWith(
        solicitudes: state.solicitudes
            .where((s) => s.id != idSolicitud)
            .toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Comprueba si ya existe solicitud para un animal concreto
  bool tieneSolicitudLocal(String idAnimal) {
    return state.solicitudes.any((s) => s.idAnimal == idAnimal);
  }
}

// Provider global
final adopcionesProvider =
    StateNotifierProvider<AdopcionesNotifier, AdopcionesState>(
  (ref) => AdopcionesNotifier(),
);

// Provider auxiliar: solo el número de solicitudes pendientes
final solicitudesPendientesProvider = Provider<int>((ref) {
  return ref
      .watch(adopcionesProvider)
      .solicitudes
      .where((s) => s.estado == 'pendiente')
      .length;
});