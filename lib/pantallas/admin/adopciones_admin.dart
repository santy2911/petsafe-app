import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../tema.dart';
import '../../modelos/solicitud_adopcion.dart';
import '../../providers/adopciones_provider.dart';

class AdminAdopcionesScreen extends ConsumerStatefulWidget {
  const AdminAdopcionesScreen({super.key});

  @override
  ConsumerState<AdminAdopcionesScreen> createState() => _AdminAdopcionesScreenState();
}

class _AdminAdopcionesScreenState extends ConsumerState<AdminAdopcionesScreen> {
  String filtroEstado = 'Todas';

  @override
  void initState() {
    super.initState();
    // Cargamos las solicitudes al entrar
    Future.microtask(() => ref.read(adopcionesProvider.notifier).cargarTodasLasSolicitudes());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adopcionesProvider);
    
    final solicitudes = state.solicitudes.where((s) {
      if (filtroEstado == 'Todas') return true;
      return s.estado.toLowerCase() == filtroEstado.toLowerCase();
    }).toList();

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        title: const Text('Gestión de Adopciones'),
        actions: [
          _buildFiltroChip('Todas'),
          _buildFiltroChip('Pendiente'),
          _buildFiltroChip('Aceptada'),
          _buildFiltroChip('Rechazada'),
          const SizedBox(width: 32),
        ],
      ),
      body: state.cargando && state.solicitudes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text('Error: ${state.error}'))
              : Padding(
                  padding: const EdgeInsets.all(32),
                  child: solicitudes.isEmpty
                      ? const Center(child: Text('No hay solicitudes con este estado'))
                      : ListView.separated(
                          itemCount: solicitudes.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final solicitud = solicitudes[index];
                            return _SolicitudCard(
                              solicitud: solicitud,
                              onAceptar: () => ref.read(adopcionesProvider.notifier).actualizarEstado(solicitud.id, 'Aceptada'),
                              onRechazar: () => ref.read(adopcionesProvider.notifier).actualizarEstado(solicitud.id, 'Rechazada'),
                            );
                          },
                        ),
                ),
    );
  }

  Widget _buildFiltroChip(String label) {
    final seleccionado = filtroEstado == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: seleccionado,
        onSelected: (val) {
          if (val) setState(() => filtroEstado = label);
        },
        selectedColor: colorPrimario.withValues(alpha: 0.2),
        labelStyle: TextStyle(
          color: seleccionado ? colorPrimario : colorTextoSuave,
          fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class _SolicitudCard extends StatelessWidget {
  final SolicitudAdopcion solicitud;
  final VoidCallback onAceptar;
  final VoidCallback onRechazar;

  const _SolicitudCard({
    required this.solicitud,
    required this.onAceptar,
    required this.onRechazar,
  });

  @override
  Widget build(BuildContext context) {
    final bool esPendiente = solicitud.estado.toLowerCase() == 'pendiente';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: colorPrimario.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_outline, color: colorPrimario),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${solicitud.nombreUsuario} desea adoptar a ${solicitud.nombreAnimal}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Solicitado el ${solicitud.fecha.day}/${solicitud.fecha.month}/${solicitud.fecha.year}',
                    style: const TextStyle(color: colorTextoSuave, fontSize: 13),
                  ),
                  if (solicitud.mensaje.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      '"${solicitud.mensaje}"',
                      style: const TextStyle(fontStyle: FontStyle.italic, color: colorTexto),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 20),
            _buildEstadoBadge(solicitud.estado),
            const SizedBox(width: 32),
            if (esPendiente) ...[
              IconButton(
                onPressed: onAceptar,
                icon: const Icon(Icons.check_circle_outline, color: colorReportar),
                tooltip: 'Aceptar',
              ),
              IconButton(
                onPressed: onRechazar,
                icon: const Icon(Icons.highlight_off, color: colorError),
                tooltip: 'Rechazar',
              ),
            ] else 
              const SizedBox(width: 96), 
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.visibility_outlined, color: colorTextoSuave),
              tooltip: 'Ver detalle',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoBadge(String estado) {
    Color color;
    switch (estado.toLowerCase()) {
      case 'aceptada': color = colorReportar; break;
      case 'rechazada': color = colorError; break;
      default: color = const Color(0xFFE65100);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        estado.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1),
      ),
    );
  }
}

