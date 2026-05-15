import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../modelos/notificacion.dart';
import '../servicios/notificaciones_service.dart';
import '../tema.dart';

class NotificacionModel {
  final String id;
  final String titulo;
  final String mensaje;
  final String tiempo;
  final String tipo;
  final String? idEntidad;
  final IconData icono;
  final Color color;
  final bool leida;

  const NotificacionModel({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.tiempo,
    required this.tipo,
    this.idEntidad,
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
      tipo: tipo,
      idEntidad: idEntidad,
      icono: icono,
      color: color,
      leida: leida ?? this.leida,
    );
  }

  factory NotificacionModel.desdeBackend(Notificacion n) {
    final ahora = DateTime.now();
    final diff = ahora.difference(n.fecha);

    String tiempo;
    if (diff.inMinutes < 1) {
      tiempo = 'Ahora mismo';
    } else if (diff.inMinutes < 60) {
      tiempo = 'Hace ${diff.inMinutes} m';
    } else if (diff.inHours < 24) {
      tiempo = 'Hace ${diff.inHours} h';
    } else {
      tiempo = 'Hace ${diff.inDays} d';
    }

    IconData icono;
    Color color;
    switch (n.tipo) {
      case 'adopcion':
        icono = Icons.favorite_rounded;
        color = colorAdoptar;
        break;
      case 'mascota_perdida':
        icono = Icons.location_on_rounded;
        color = colorAcento;
        break;
      case 'recompensa':
        icono = Icons.emoji_events_rounded;
        color = Colors.amber;
        break;
      default:
        icono = Icons.info_outline_rounded;
        color = colorPrimario;
    }

    return NotificacionModel(
      id: n.id,
      titulo: n.titulo,
      mensaje: n.mensaje,
      tiempo: tiempo,
      tipo: n.tipo,
      idEntidad: n.idEntidad,
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
      // Mock inicial si falla
      state = [];
    }
  }

  Future<void> marcarComoLeida(String id) async {
    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(leida: true) else n,
    ];
    // En el futuro llamar al servicio
  }

  Future<void> leerTodas() async {
    state = state.map((n) => n.copyWith(leida: true)).toList();
  }

  void agregarNotificacion({
    required String titulo,
    required String mensaje,
    required String tipo,
    String? idEntidad,
  }) {
    final nueva = NotificacionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: titulo,
      mensaje: mensaje,
      tiempo: 'Ahora mismo',
      tipo: tipo,
      idEntidad: idEntidad,
      icono: _getIconForTipo(tipo),
      color: _getColorForTipo(tipo),
      leida: false,
    );
    state = [nueva, ...state];
  }

  IconData _getIconForTipo(String tipo) {
    switch (tipo) {
      case 'adopcion': return Icons.favorite_rounded;
      case 'mascota_perdida': return Icons.location_on_rounded;
      case 'recompensa': return Icons.emoji_events_rounded;
      default: return Icons.info_outline_rounded;
    }
  }

  Color _getColorForTipo(String tipo) {
    switch (tipo) {
      case 'adopcion': return colorAdoptar;
      case 'mascota_perdida': return colorAcento;
      case 'recompensa': return Colors.amber;
      default: return colorPrimario;
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