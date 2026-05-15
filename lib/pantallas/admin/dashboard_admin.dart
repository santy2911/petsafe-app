import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../tema.dart';
import '../../providers/animales_provider.dart';
import '../../providers/adopciones_provider.dart';
import '../../providers/reportes_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animalesState = ref.watch(animalesProvider);
    final adopcionesState = ref.watch(adopcionesProvider);
    final reportesState = ref.watch(reportesProvider);

    final animalesDisponibles = animalesState.animales
        .where((a) => a.estado.toLowerCase() == 'disponible')
        .length;
    final adopcionesPendientes = adopcionesState.solicitudes
        .where((s) => s.estado.toLowerCase() == 'pendiente')
        .length;
    final reportesActivos = reportesState.reportes
        .where((r) => !r.encontrado)
        .length;

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        title: const Text('Dashboard de Administración'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(animalesProvider.notifier).recargar();
              ref.read(adopcionesProvider.notifier).cargarTodasLasSolicitudes();
              ref.read(reportesProvider.notifier).cargarReportes();
            },
            icon: const Icon(Icons.refresh_rounded, color: colorTextoSuave),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen del Sistema',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorTexto,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Estadísticas en tiempo real de los refugios y usuarios.',
              style: TextStyle(color: colorTextoSuave),
            ),
            const SizedBox(height: 32),
            
            // Grid de tarjetas de estadisticas
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 600 ? 2 : 1);
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: 1.5,
                  children: [
                    _StatCard(
                      label: 'Animales Disponibles',
                      value: animalesDisponibles.toString(),
                      icon: Icons.pets,
                      color: colorPrimario,
                    ),
                    _StatCard(
                      label: 'Adopciones Pendientes',
                      value: adopcionesPendientes.toString(),
                      icon: Icons.favorite,
                      color: colorAdoptar,
                    ),
                    _StatCard(
                      label: 'Reportes Activos',
                      value: reportesActivos.toString(),
                      icon: Icons.warning_amber_rounded,
                      color: colorAcento,
                    ),
                    _StatCard(
                      label: 'Usuarios Registrados',
                      value: '124', // Mock por ahora
                      icon: Icons.people,
                      color: colorTexto,
                    ),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 48),
            
            // Seccion de actividad reciente
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Actividad Reciente',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          if (adopcionesState.solicitudes.isNotEmpty)
                            _ActivityItem(
                              user: adopcionesState.solicitudes.first.nombreUsuario,
                              action: 'ha solicitado adoptar a "${adopcionesState.solicitudes.first.nombreAnimal}"',
                              time: 'Reciente',
                              icon: Icons.favorite,
                              iconColor: colorAdoptar,
                            ),
                          if (reportesState.reportes.isNotEmpty)
                            _ActivityItem(
                              user: 'Comunidad',
                              action: 'ha reportado a "${reportesState.reportes.first.nombre}" como perdido',
                              time: 'Hace poco',
                              icon: Icons.location_on,
                              iconColor: colorAcento,
                            ),
                          _ActivityItem(
                            user: 'Admin',
                            action: 'ha actualizado el catálogo de animales',
                            time: 'Hace 1 hora',
                            icon: Icons.add_circle_outline,
                            iconColor: colorPrimario,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Estado del Sistema',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 24),
                          const _StatusIndicator(label: 'Servidor API', status: 'Online', color: colorPrimario),
                          const SizedBox(height: 16),
                          const _StatusIndicator(label: 'Base de Datos', status: 'Conectado', color: colorPrimario),
                          const SizedBox(height: 16),
                          const _StatusIndicator(label: 'Servicio Notificaciones', status: 'Online', color: colorPrimario),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const Icon(Icons.trending_up, color: Colors.green, size: 20),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: colorTexto),
            ),
            Text(
              label,
              style: const TextStyle(color: colorTextoSuave, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String user;
  final String action;
  final String time;
  final IconData icon;
  final Color iconColor;

  const _ActivityItem({
    required this.user,
    required this.action,
    required this.time,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: colorTexto, fontSize: 14),
                    children: [
                      TextSpan(text: user, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: ' '),
                      TextSpan(text: action),
                    ],
                  ),
                ),
                Text(time, style: const TextStyle(color: colorTextoSuave, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final String label;
  final String status;
  final Color color;

  const _StatusIndicator({required this.label, required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: colorTexto, fontWeight: FontWeight.w500)),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}
