import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../modelos/solicitud_adopcion.dart';
import '../servicios/adopciones_service.dart';
import '../datos/solicitudes_mock.dart';
import 'notificaciones_provider.dart';
import '../servicios/email_service.dart';

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
  final Ref _ref;

  AdopcionesNotifier(this._ref) : super(const AdopcionesState()) {
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

  // Carga TODAS las solicitudes (vista Admin)
  Future<void> cargarTodasLasSolicitudes() async {
    state = state.copyWith(cargando: true);
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      state = state.copyWith(solicitudes: solicitudesMock, cargando: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), cargando: false);
    }
  }

  // Enviar una nueva solicitud de adopción
  Future<bool> crearSolicitud({
    required String idAnimal,
    required String comentarios,
  }) async {
    if (state.solicitudes.any((s) => s.idAnimal == idAnimal)) {
      return false;
    }
    state = state.copyWith(cargando: true);
    try {
      final nueva = await AdopcionesService.crearSolicitud(
        idAnimal: idAnimal,
        comentarios: comentarios,
      );
      if (state.solicitudes.any((s) => s.idAnimal == idAnimal)) {
        state = state.copyWith(cargando: false);
        return false;
      }
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

  // Cambiar estado (Admin)
  Future<void> actualizarEstado(String id, String nuevoEstado) async {
    state = state.copyWith(cargando: true);
    try {
      await AdopcionesService.actualizarEstado(id, nuevoEstado);
      
      final solicitudes = state.solicitudes.map((s) {
        if (s.id == id) {
          // Disparamos notificación local
          final mensaje = nuevoEstado.toLowerCase() == 'aceptada' 
              ? '¡Felicidades! Tu solicitud para adoptar a ${s.nombreAnimal} ha sido ACEPTADA.' 
              : 'Lo sentimos, tu solicitud para adoptar a ${s.nombreAnimal} ha sido rechazada.';
          
          _ref.read(notificacionesProvider.notifier).agregarNotificacion(
            titulo: 'Estado de Adopción',
            mensaje: mensaje,
            tipo: 'adopcion',
          );

          // ENVIAR EMAIL (RF-64)
          EmailService.enviarEmail(
            destinatario: 'usuario@ejemplo.com', // En el futuro usar el email real del solicitante
            asunto: 'Actualización de tu solicitud de adopción - PetSafe',
            cuerpo: 'Hola ${s.nombreUsuario},\n\n$mensaje\n\nGracias por confiar en PetSafe.',
          );

          return s.copyWith(estado: nuevoEstado);
        }
        return s;
      }).toList();
      
      state = state.copyWith(solicitudes: solicitudes, cargando: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), cargando: false);
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
  (ref) => AdopcionesNotifier(ref),
);

// Provider auxiliar: solo el número de solicitudes pendientes
final solicitudesPendientesProvider = Provider<int>((ref) {
  return ref
      .watch(adopcionesProvider)
      .solicitudes
      .where((s) => s.estado.toLowerCase() == 'pendiente')
      .length;
});