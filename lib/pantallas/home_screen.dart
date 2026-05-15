import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../tema.dart';
import '../modelos/animal.dart';
import '../providers/animales_provider.dart';
import '../providers/reportes_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/boton_notificaciones.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).usuarioActual;
    final animalesState = ref.watch(animalesProvider);
    final reportesState = ref.watch(reportesProvider);

    final animalesDisponibles = animalesState.animales
        .where((a) => a.estado.toLowerCase() == 'disponible')
        .toList();
    final reportesActivos = reportesState.reportes
        .where((r) => !r.encontrado)
        .toList();

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        title: const Text('PetSafe'),
        actions: [
          const BotonNotificaciones(),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, ${user?.nombre ?? 'Usuario'} 👋',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              '¿Cómo podemos ayudarte hoy?',
              style: TextStyle(color: colorTextoSuave, fontSize: 16),
            ),
            const SizedBox(height: 32),

            // Accesos rapidos
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    label: 'Adoptar',
                    icon: Icons.favorite_rounded,
                    color: colorAdoptar,
                    onTap: () => context.go('/catalogo'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _QuickActionCard(
                    label: 'Mapa',
                    icon: Icons.map_rounded,
                    color: colorMapa,
                    onTap: () => context.go('/mapa'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _QuickActionCard(
                    label: 'Reportar',
                    icon: Icons.campaign_rounded,
                    color: colorPerdidas,
                    onTap: () => context.go('/reportar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),

            // Sección Adopción
            _buildSectionHeader('En adopción', 'Ver todos', () => context.go('/catalogo')),
            const SizedBox(height: 20),
            if (animalesState.cargando && animalesState.animales.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (animalesDisponibles.isEmpty)
              const Text('No hay animales disponibles en este momento.')
            else
              _FilaAnimalesHorizontales(
                animales: animalesDisponibles,
                onAnimalTap: (animal) => context.go('/animal/${animal.id}', extra: animal),
              ),
            const SizedBox(height: 48),

            // Sección Perdidos
            _buildSectionHeader('Mascotas perdidas', 'Ver mapa', () => context.go('/mapa')),
            const SizedBox(height: 20),
            if (reportesState.cargando && reportesState.reportes.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (reportesActivos.isEmpty)
              const Text('No hay reportes activos.')
            else
              ...reportesActivos.take(3).map((reporte) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Card(
                  color: colorAcentoLight,
                  surfaceTintColor: Colors.transparent,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(reporte.imagenUrl, width: 60, height: 60, fit: BoxFit.cover),
                    ),
                    title: Text(reporte.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(reporte.direccion, maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.go('/mapa', extra: reporte),
                  ),
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String actionLabel, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        TextButton(onPressed: onTap, child: Text(actionLabel)),
      ],
    );
  }
}

class _FilaAnimalesHorizontales extends StatelessWidget {
  final List<Animal> animales;
  final void Function(Animal) onAnimalTap;

  const _FilaAnimalesHorizontales({
    required this.animales,
    required this.onAnimalTap,
  });

  static const double _alto = 280;
  static const double _anchoTarjeta = 200;
  static const double _margenDcha = 20;

  @override
  Widget build(BuildContext context) {
    final n = animales.length;
    if (n == 0) return const SizedBox.shrink();

    return SizedBox(
      height: _alto,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: n,
        itemBuilder: (context, i) {
          final animal = animales[i];
          return Container(
            width: _anchoTarjeta,
            margin: EdgeInsets.only(right: i == n - 1 ? 0 : _margenDcha),
            child: InkWell(
              onTap: () => onAnimalTap(animal),
              borderRadius: BorderRadius.circular(24),
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      child: Image.network(
                        animal.imagenUrl,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 160,
                          color: colorFondo,
                          child: const Icon(Icons.pets_rounded, color: colorTextoSuave, size: 48),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(animal.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('${animal.raza} • ${animal.edad} años', style: const TextStyle(color: colorTextoSuave, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
