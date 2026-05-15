import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../tema.dart';
import '../../modelos/reporte.dart';
import '../../providers/reportes_provider.dart';

class AdminReportesScreen extends ConsumerStatefulWidget {
  const AdminReportesScreen({super.key});

  @override
  ConsumerState<AdminReportesScreen> createState() => _AdminReportesScreenState();
}

class _AdminReportesScreenState extends ConsumerState<AdminReportesScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportesProvider);

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        title: const Text('Gestión de Reportes de Extravío'),
      ),
      body: state.cargando && state.reportes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(32),
              child: state.reportes.isEmpty
                  ? const Center(child: Text('No hay reportes registrados'))
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 500,
                        mainAxisExtent: 220,
                        crossAxisSpacing: 24,
                        mainAxisSpacing: 24,
                      ),
                      itemCount: state.reportes.length,
                      itemBuilder: (context, index) {
                        final reporte = state.reportes[index];
                        return _ReporteAdminCard(
                          reporte: reporte,
                          onMarcarEncontrado: () => ref.read(reportesProvider.notifier).marcarEncontrado(reporte.id),
                          onEliminar: () => _confirmarEliminar(context, reporte),
                          onVerEnMapa: () => context.go('/mapa', extra: reporte),
                        );
                      },
                    ),
            ),
    );
  }

  void _confirmarEliminar(BuildContext context, Reporte reporte) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Reporte'),
        content: Text('¿Estás seguro de que quieres eliminar el reporte de ${reporte.nombre}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              ref.read(reportesProvider.notifier).eliminar(reporte.id);
              Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: colorError)),
          ),
        ],
      ),
    );
  }
}

class _ReporteAdminCard extends StatelessWidget {
  final Reporte reporte;
  final VoidCallback onMarcarEncontrado;
  final VoidCallback onEliminar;
  final VoidCallback onVerEnMapa;

  const _ReporteAdminCard({
    required this.reporte,
    required this.onMarcarEncontrado,
    required this.onEliminar,
    required this.onVerEnMapa,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                reporte.imagenUrl,
                width: 120,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 120,
                  color: colorFondo,
                  child: const Icon(Icons.pets, color: colorTextoSuave),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        reporte.nombre,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      _StatusBadge(encontrado: reporte.encontrado),
                    ],
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: onVerEnMapa,
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: colorPrimario),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            reporte.direccion,
                            style: const TextStyle(color: colorPrimario, fontSize: 12, fontWeight: FontWeight.w500, decoration: TextDecoration.underline),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    reporte.descripcion,
                    style: const TextStyle(color: colorTextoSuave, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      if (!reporte.encontrado)
                        TextButton.icon(
                          onPressed: onMarcarEncontrado,
                          icon: const Icon(Icons.check_circle_outline, size: 18),
                          label: const Text('Logrado'),
                          style: TextButton.styleFrom(foregroundColor: colorReportar),
                        ),
                      const Spacer(),
                      IconButton(
                        onPressed: onEliminar,
                        icon: const Icon(Icons.delete_outline, color: colorError, size: 20),
                        tooltip: 'Eliminar reporte',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool encontrado;
  const _StatusBadge({required this.encontrado});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: encontrado ? colorReportar.withValues(alpha: 0.1) : colorPerdidas.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        encontrado ? 'ENCONTRADO' : 'PERDIDO',
        style: TextStyle(
          color: encontrado ? colorReportar : colorPerdidas,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

