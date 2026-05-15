import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../modelos/animal.dart';
import '../tema.dart';

class AnimalCard extends StatelessWidget {
  final Animal animal;

  const AnimalCard({super.key, required this.animal});

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => context.go('/animal/${animal.id}', extra: animal),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colores.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colores.outlineVariant.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                animal.imagenUrl,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 64,
                  height: 64,
                  color: colores.surfaceContainerHighest,
                  child: Icon(Icons.pets, color: colores.onSurfaceVariant, size: 32),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    animal.nombre,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colores.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${animal.raza} · ${animal.edad} ${animal.edad == 1 ? 'año' : 'años'} · ${animal.sexo}',
                    style: TextStyle(
                      fontSize: 13,
                      color: colores.onSurface.withOpacity(0.55),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorAdoptar,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: const [
                  Text(
                    'Ver más',
                    style: TextStyle(
                      color: colorBlanco,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(Icons.chevron_right, color: colorBlanco, size: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}