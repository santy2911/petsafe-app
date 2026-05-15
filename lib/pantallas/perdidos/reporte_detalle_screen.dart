import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../modelos/reporte.dart';
import '../../tema.dart';
import '../../providers/reportes_provider.dart';
import '../../providers/auth_provider.dart';

class ReporteDetalleScreen extends ConsumerWidget {
  final Reporte reporte;

  const ReporteDetalleScreen({super.key, required this.reporte});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final reportesState = ref.watch(reportesProvider);
    
    // Obtenemos la versión más reciente del reporte del provider por si ha cambiado
    final reporteActual = reportesState.reportes.firstWhere(
      (r) => r.id == reporte.id, 
      orElse: () => reporte
    );

    final esAutor = authState.usuarioActual?.id == reporteActual.idUsuario;
    final esAdmin = authState.usuarioActual?.rol == 'Admin';
    final puedeMarcarComoEncontrado = (esAutor || esAdmin) && !reporteActual.encontrado;

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        title: const Text('Detalle del Reporte'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner de éxito si fue encontrado
            if (reporteActual.encontrado)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                color: Colors.green,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      '¡ESTA MASCOTA HA SIDO ENCONTRADA!',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ],
                ),
              ),

            // Imagen
            if (reporteActual.imagenUrl.isNotEmpty)
              Image.network(
                reporteActual.imagenUrl,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Icon(Icons.pets_rounded, size: 64, color: Colors.grey),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatusChip(estado: reporteActual.encontrado ? 'Encontrado' : 'Perdido'),
                      Text(
                        'Reportado el ${reporteActual.fecha.toString().split(' ')[0]}',
                        style: const TextStyle(color: colorTextoSuave, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    reporteActual.descripcion,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: colorPrimario.withValues(alpha: 0.1),
                      child: const Icon(Icons.person_rounded, color: colorPrimario),
                    ),
                    title: const Text('Reportado por', style: TextStyle(color: colorTextoSuave, fontSize: 12)),
                    subtitle: const Text('Usuario PetSafe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  
                  const SizedBox(height: 32),
                  const Text('Ubicación del avistamiento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(reporteActual.latitud, reporteActual.longitud),
                        initialZoom: 15,
                        interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(reporteActual.latitud, reporteActual.longitud),
                              width: 40,
                              height: 40,
                              child: Icon(
                                Icons.location_on_rounded,
                                color: reporteActual.encontrado ? colorPrimario : colorAcento,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.place_rounded, color: colorTextoSuave, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          reporteActual.direccion,
                          style: const TextStyle(color: colorTextoSuave, fontSize: 14),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),
                  if (puedeMarcarComoEncontrado)
                    ElevatedButton.icon(
                      onPressed: () => _confirmarEncontrado(context, ref, reporteActual.id),
                      icon: const Icon(Icons.check_circle_rounded),
                      label: const Text('Marcar como encontrado', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorPrimario,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarEncontrado(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Has encontrado a la mascota?'),
        content: const Text('Este reporte se marcará como solucionado y ya no aparecerá como "Perdido" en el mapa público.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              ref.read(reportesProvider.notifier).marcarEncontrado(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('¡Excelente! El reporte ha sido actualizado.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Sí, encontrado'),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String estado;
  const _StatusChip({required this.estado});

  @override
  Widget build(BuildContext context) {
    final bool esEncontrado = estado.toLowerCase() == 'encontrado';
    final Color color = esEncontrado ? colorPrimario : colorAcento;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            estado.toUpperCase(),
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}
