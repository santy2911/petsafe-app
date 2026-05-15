import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../tema.dart';
import '../providers/notificaciones_provider.dart';

// Pantalla de notificaciones
class NotificacionesScreen extends ConsumerWidget {
  const NotificacionesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colores = Theme.of(context).colorScheme;

    final notificaciones = ref.watch(notificacionesProvider);
    final notifier = ref.read(notificacionesProvider.notifier);
    final noLeidas = ref.watch(noLeidasProvider);

    return Scaffold(
      backgroundColor: colores.surface,
      appBar: AppBar(
        backgroundColor: colorPrimario,
        foregroundColor: colorBlanco,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/home'),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notificaciones',
              style: TextStyle(
                color: colorBlanco,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            if (noLeidas > 0)
              Text(
                '$noLeidas sin leer',
                style: TextStyle(
                  color: colorBlanco.withValues(alpha: 0.8),
                  fontSize: 11,
                ),
              ),
          ],
        ),
        actions: [
          if (noLeidas > 0)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () => notifier.leerTodas(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorBlanco.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colorBlanco.withValues(alpha: 0.4), width: 1),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.done_all_rounded, color: colorBlanco, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Leer todas',
                        style: TextStyle(
                          color: colorBlanco,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: notificaciones.isEmpty
          ? _buildVacio(colores)
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: notificaciones.length,
              itemBuilder: (context, i) {
                return _TarjetaNotificacion(
                  notificacion: notificaciones[i],
                  alPulsar: () => notifier.marcarComoLeida(i),
                  colores: colores,
                );
              },
            ),
    );
  }

  Widget _buildVacio(ColorScheme colores) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 64,
            color: colores.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Sin notificaciones',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colores.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Aquí aparecerán tus avisos',
            style: TextStyle(fontSize: 13, color: colores.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _TarjetaNotificacion extends StatelessWidget {
  final NotificacionModel notificacion;
  final VoidCallback alPulsar;
  final ColorScheme colores;

  const _TarjetaNotificacion({
    required this.notificacion,
    required this.alPulsar,
    required this.colores,
  });

  @override
  Widget build(BuildContext context) {
    final leida = notificacion.leida;

    final colorTarjeta = leida
        ? colores.surfaceContainer
        : colores.surfaceContainerHighest;

    final colorIconoFondo = leida
        ? colores.onSurface.withValues(alpha: 0.06)
        : notificacion.color.withValues(alpha: 0.18);

    final icono = leida ? Icons.notifications_none_rounded : notificacion.icono;
    final colorIcono = leida ? colores.onSurfaceVariant : notificacion.color;
    final colorTitulo = leida ? colores.onSurfaceVariant : colores.onSurface;
    final pesoTitulo = leida ? FontWeight.normal : FontWeight.bold;

    return GestureDetector(
      onTap: alPulsar,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: colorTarjeta,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorIconoFondo,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icono, color: colorIcono, size: 22),
          ),
          title: Text(
            notificacion.titulo,
            style: TextStyle(
              fontWeight: pesoTitulo,
              fontSize: 14,
              color: colorTitulo,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 3),
              Text(
                notificacion.mensaje,
                style: TextStyle(fontSize: 12, color: colores.onSurfaceVariant),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                notificacion.tiempo,
                style: TextStyle(
                  fontSize: 11,
                  color: colores.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          trailing: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: leida
                ? const SizedBox(key: ValueKey('leida'), width: 8)
                : Container(
                    key: const ValueKey('punto'),
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: colorPrimario,
                      shape: BoxShape.circle,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
