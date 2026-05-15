import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../tema.dart';
import '../widgets/navbar.dart';
import '../datos/animales_mock.dart';
import '../datos/reportes_mock.dart';
import '../providers/notificaciones_provider.dart';

// Pantalla principal de la app
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noLeidas = ref.watch(noLeidasProvider);
    final colores = Theme.of(context).colorScheme;

    final animalesAleatorios = [...animalesMock]..shuffle();

    return Scaffold(
      backgroundColor: colores.surface,
      bottomNavigationBar: const NavbarPrincipal(indiceActual: 0),
      body: Column(
        children: [
          _buildCabecera(context, noLeidas),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBotonesRapidos(context, colores),
                  const SizedBox(height: 28),
                  _buildSeccionAdopcion(context, colores, animalesAleatorios),
                  const SizedBox(height: 28),
                  _buildSeccionPerdidas(context, colores),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCabecera(BuildContext context, int noLeidas) {
    return ClipPath(
      clipper: _CabeceraCurvaClipper(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 60, bottom: 60, left: 24, right: 24),
        color: colorPrimario,
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              const Positioned(
                top: 0,
                right: 50,
                child: Opacity(
                  opacity: 0.15,
                  child: Icon(Icons.pets, size: 70, color: colorBlanco),
                ),
              ),
              const Positioned(
                bottom: 10,
                right: 10,
                child: Opacity(
                  opacity: 0.10,
                  child: Icon(Icons.pets, size: 45, color: colorBlanco),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => context.go('/notificaciones'),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: colorBlanco.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: colorBlanco,
                          size: 22,
                        ),
                      ),
                      if (noLeidas > 0)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: colorPerdidas,
                              shape: BoxShape.circle,
                              border: Border.all(color: colorPrimario, width: 1.5),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HOME',
                    style: TextStyle(
                      color: colorBlanco,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Hola, Usuario 👋',
                    style: TextStyle(
                      color: colorBlanco,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '¿Cómo podemos ayudarte hoy?',
                    style: TextStyle(color: colorBlanco, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBotonesRapidos(BuildContext context, ColorScheme colores) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _BotonRapido(
              icono: Icons.favorite,
              label: 'Adoptar\nmascotas',
              color: colorAdoptar.withValues(alpha: 0.15),
              colorIcono: colorAdoptar,
              alPresionar: () => context.go('/catalogo'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _BotonRapido(
              icono: Icons.location_on,
              label: 'Mascotas\nperdidas',
              color: const Color(0xFFE65100).withValues(alpha: 0.15),
              colorIcono: const Color(0xFFE65100),
              alPresionar: () => context.go('/mapa'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _BotonRapido(
              icono: Icons.campaign_outlined,
              label: 'Reportar\nmascota',
              color: colorReportar.withValues(alpha: 0.15),
              colorIcono: colorReportar,
              alPresionar: () => context.go('/reportar'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionAdopcion(BuildContext context, ColorScheme colores, List animalesAleatorios) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite, color: colorPerdidas, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'En adopción',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colores.onSurface,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => context.go('/catalogo'),
                child: const Text(
                  'Ver todos ›',
                  style: TextStyle(
                    color: colorPrimario,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: animalesAleatorios.length,
            itemBuilder: (context, i) {
              final animal = animalesAleatorios[i];
              return GestureDetector(
                onTap: () => context.go('/animal/${animal.id}', extra: animal),
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: colores.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Image.network(
                          animal.imagenUrl,
                          height: 110,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            height: 110,
                            color: colorPrimario.withValues(alpha: 0.15),
                            child: const Icon(Icons.pets, color: colorPrimario, size: 40),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              animal.nombre,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: colores.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              animal.raza,
                              style: TextStyle(
                                fontSize: 11,
                                color: colores.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${animal.edad} años',
                              style: TextStyle(
                                fontSize: 11,
                                color: colores.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSeccionPerdidas(BuildContext context, ColorScheme colores) {
    final reportes = reportesMock.where((r) => !r.encontrado).take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFE65100),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Mascotas perdidas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colores.onSurface,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => context.go('/mapa'),
                child: const Text(
                  'Ver mapa ›',
                  style: TextStyle(
                    color: colorPrimario,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: reportes.map((reporte) {
              return GestureDetector(
                // Navega al mapa pasando el reporte para centrar y abrir modal
                onTap: () => context.go('/mapa', extra: reporte),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colores.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          reporte.imagenUrl,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            width: 56,
                            height: 56,
                            color: colorPrimario.withValues(alpha: 0.15),
                            child: const Icon(Icons.pets, color: colorPrimario),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reporte.nombre,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: colores.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              reporte.descripcion,
                              style: TextStyle(
                                fontSize: 12,
                                color: colores.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    size: 12, color: colorPrimario),
                                const SizedBox(width: 2),
                                Expanded(
                                  child: Text(
                                    reporte.direccion,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: colorPrimario,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE65100).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'PERDIDO',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE65100),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _BotonRapido extends StatelessWidget {
  final IconData icono;
  final String label;
  final Color color;
  final Color colorIcono;
  final VoidCallback alPresionar;

  const _BotonRapido({
    required this.icono,
    required this.label,
    required this.color,
    required this.colorIcono,
    required this.alPresionar,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: alPresionar,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icono, color: colorIcono, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorIcono,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CabeceraCurvaClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(
      size.width / 2,
      size.height - 40,
      size.width,
      size.height,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_CabeceraCurvaClipper oldClipper) => false;
}
