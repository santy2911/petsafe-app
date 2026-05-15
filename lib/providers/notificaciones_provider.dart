import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../modelos/notificacion.dart';
import '../servicios/notificaciones_service.dart';
import '../tema.dart';

// NotificacionModel se mantiene para que las pantallas existentes
// no necesiten cambios — se construye desde Notificacion del backend
class NotificacionModel {
  final String id;
  final String titulo;
  final String mensaje;
  final String tiempo;
  final IconData icono;
  final Color color;
  final bool leida;

  const NotificacionModel({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.tiempo,
    required this.icono,
    required this.color,
    this.leida = false,
  });

  NotificacionModel copyWith({bool? leida}) {
    return NotificacionModel(
      id: id,
      titulo: titulo,
      mensaje: mensaje,
      tiempo: tiempo,
      icono: icono,
      color: color,
      leida: leida ?? this.leida,
    );
  }

  // Convierte Notificacion del backend a NotificacionModel para la UI
  factory NotificacionModel.desdeBackend(Notificacion n) {
    final ahora = DateTime.now();
    final diff = ahora.difference(n.fecha);

    String tiempo;
    if (diff.inMinutes < 60) {
      tiempo = 'Hace ${diff.inMinutes} minutos';
    } else if (diff.inHours < 24) {
      tiempo = 'Hace ${diff.inHours} horas';
    } else {
      tiempo = 'Hace ${diff.inDays} días';
    }

    IconData icono;
    Color color;
    switch (n.tipo) {
      case 'adopcion':
        icono = Icons.favorite_rounded;
        color = colorPerdidas;
        break;
      case 'mascota_perdida':
        icono = Icons.location_on_rounded;
        color = colorPerdidas;
        break;
      case 'recompensa':
        icono = Icons.star_rounded;
        color = colorAdoptar;
        break;
      default:
        icono = Icons.notifications_rounded;
        color = colorReportar;
    }

    return NotificacionModel(
      id: n.id,
      titulo: n.titulo,
      mensaje: n.mensaje,
      tiempo: tiempo,
      icono: icono,
      color: color,
      leida: n.leida,
    );
  }
}

class NotificacionesNotifier extends StateNotifier<List<NotificacionModel>> {
  NotificacionesNotifier() : super([]) {
    cargarNotificaciones();
  }

  Future<void> cargarNotificaciones() async {
    try {
      final datos = await NotificacionesService.getNotificaciones();
      state = datos.map(NotificacionModel.desdeBackend).toList();
    } catch (e) {
      // Si falla, queda vacío sin romper la pantalla
    }
  }

  Future<void> marcarComoLeida(int index) async {
    try {
      await NotificacionesService.marcarLeida(state[index].id);
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index) state[i].copyWith(leida: true) else state[i],
      ];
    } catch (e) {
      // Actualiza la UI igual aunque falle el servidor
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index) state[i].copyWith(leida: true) else state[i],
      ];
    }
  }

  Future<void> leerTodas() async {
    try {
      await NotificacionesService.marcarTodasLeidas();
    } finally {
      state = state.map((n) => n.copyWith(leida: true)).toList();
    }
  }
}

final notificacionesProvider =
    StateNotifierProvider<NotificacionesNotifier, List<NotificacionModel>>(
  (ref) => NotificacionesNotifier(),
);

final noLeidasProvider = Provider<int>((ref) {
  return ref.watch(notificacionesProvider).where((n) => !n.leida).length;
});