import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../tema.dart';
import '../../providers/notificaciones_provider.dart';
import '../../providers/reportes_provider.dart';
import '../../providers/animales_provider.dart';

class NotificacionesScreen extends ConsumerWidget {
  const NotificacionesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificaciones = ref.watch(notificacionesProvider);

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          if (notificaciones.any((n) => !n.leida))
            TextButton(
              onPressed: () => ref.read(notificacionesProvider.notifier).leerTodas(),
              child: const Text('Marcar todas como leídas'),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: notificaciones.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notificaciones.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final n = notificaciones[index];
                return _NotificacionCard(notificacion: n);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20),
              ],
            ),
            child: Icon(Icons.notifications_off_rounded, size: 64, color: Colors.grey[300]),
          ),
          const SizedBox(height: 24),
          const Text(
            'No tienes notificaciones',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorTexto),
          ),
          const SizedBox(height: 8),
          const Text(
            'Te avisaremos cuando pase algo importante',
            style: TextStyle(color: colorTextoSuave),
          ),
        ],
      ),
    );
  }
}

class _NotificacionCard extends ConsumerWidget {
  final NotificacionModel notificacion;
  const _NotificacionCard({required this.notificacion});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 0,
      color: notificacion.leida ? Colors.white : const Color(0xFFF0F7FF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: notificacion.leida ? Colors.transparent : colorPrimario.withValues(alpha: 0.2),
        ),
      ),
      child: InkWell(
        onTap: () => _handleTap(context, ref),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: notificacion.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(notificacion.icono, color: notificacion.color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          notificacion.titulo,
                          style: TextStyle(
                            fontWeight: notificacion.leida ? FontWeight.bold : FontWeight.w900,
                            fontSize: 15,
                            color: colorTexto,
                          ),
                        ),
                        Text(
                          notificacion.tiempo,
                          style: const TextStyle(color: colorTextoSuave, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notificacion.mensaje,
                      style: TextStyle(
                        color: notificacion.leida ? colorTextoSuave : colorTexto,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (!notificacion.leida)
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(color: colorPrimario, shape: BoxShape.circle),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, WidgetRef ref) {
    ref.read(notificacionesProvider.notifier).marcarComoLeida(notificacion.id);

    if (notificacion.idEntidad != null) {
      if (notificacion.tipo == 'adopcion') {
        final animal = ref.read(animalesProvider).animales.firstWhere(
          (a) => a.id == notificacion.idEntidad,
          orElse: () => throw 'Animal no encontrado',
        );
        context.go('/animal/${animal.id}', extra: animal);
      } else if (notificacion.tipo == 'mascota_perdida') {
        final reporte = ref.read(reportesProvider).reportes.firstWhere(
          (r) => r.id == notificacion.idEntidad,
          orElse: () => throw 'Reporte no encontrado',
        );
        context.go('/reporte/${reporte.id}', extra: reporte);
      }
    }
  }
}
