import 'package:flutter/material.dart';
import '../../tema.dart';
import '../../modelos/animal.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/animales_provider.dart';
import '../../widgets/boton_notificaciones.dart';
import '../../widgets/estados_vistas.dart';

class CatalogoScreen extends ConsumerStatefulWidget {
  const CatalogoScreen({super.key});

  @override
  ConsumerState<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends ConsumerState<CatalogoScreen> {
  final _busquedaController = TextEditingController();
  String _filtro = '';
  String _especieFiltro = 'Todos';

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  List<Animal> get _animalesFiltrados {
    final textoFiltro = _filtro.toLowerCase();
    final animales = ref.watch(animalesProvider).animales;

    return animales.where((a) {
      final coincideTexto =
          a.nombre.toLowerCase().contains(textoFiltro) ||
          a.raza.toLowerCase().contains(textoFiltro) ||
          a.especie.toLowerCase().contains(textoFiltro);
      final coincideEspecie =
          _especieFiltro == 'Todos' || a.especie == _especieFiltro;

      return coincideTexto && coincideEspecie;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final animalesState = ref.watch(animalesProvider);
    final animalesFiltrados = _animalesFiltrados;

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        title: const Text('Catálogo de Adopción'),
        actions: [
          const BotonNotificaciones(),
          const SizedBox(width: 8),
          IconButton(
            onPressed: animalesState.cargando ? null : () => ref.read(animalesProvider.notifier).cargarAnimales(),
            icon: animalesState.cargando 
                ? const SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(strokeWidth: 2, color: colorPrimario)
                  )
                : const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                TextField(
                  controller: _busquedaController,
                  onChanged: (v) => setState(() => _filtro = v),
                  decoration: const InputDecoration(
                    hintText: 'Buscar por nombre o raza...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildTab('Todos', Icons.pets),
                    const SizedBox(width: 12),
                    _buildTab('Perro', Icons.pets_outlined),
                    const SizedBox(width: 12),
                    _buildTab('Gato', Icons.pets_outlined),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: _buildContent(animalesState, animalesFiltrados),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AnimalesState state, List<Animal> filtrados) {
    if (state.cargando && state.animales.isEmpty) {
      return const LoadingStateWidget();
    }

    if (state.error != null && state.animales.isEmpty) {
      return ErrorStateWidget(
        mensaje: state.error!,
        onRetry: () => ref.read(animalesProvider.notifier).cargarAnimales(),
      );
    }

    if (filtrados.isEmpty) {
      return const EmptyStateWidget(
        icono: Icons.pets_rounded,
        titulo: 'No se encontraron animales',
        subtitulo: 'Prueba a cambiar los filtros o el texto de búsqueda.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: filtrados.length,
      itemBuilder: (context, index) {
        final animal = filtrados[index];
        return _AnimalListTile(animal: animal);
      },
    );
  }

  Widget _buildTab(String label, IconData icon) {
    final bool activo = _especieFiltro == label;
    return GestureDetector(
      onTap: () => setState(() => _especieFiltro = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: activo ? colorPrimario : colorBlanco,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: activo ? colorPrimario : const Color(0xFFEBF2F0)),
        ),
        child: Row(
          children: [
            Icon(icon, color: activo ? colorBlanco : colorTextoSuave, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: activo ? colorBlanco : colorTexto,
                fontWeight: activo ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimalListTile extends StatelessWidget {
  final Animal animal;
  const _AnimalListTile({required this.animal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: InkWell(
          onTap: () => context.push('/animal/${animal.id}', extra: animal),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Hero(
                  tag: 'animal_${animal.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      animal.imagenUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
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
                          Text(animal.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          if (animal.disponible)
                            _StatusBadge(label: 'Disponible', color: colorPrimario),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(animal.raza, style: const TextStyle(color: colorTextoSuave, fontSize: 14)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _DataChip(label: '${animal.edad} años'),
                          const SizedBox(width: 8),
                          _DataChip(label: animal.sexo),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }
}

class _DataChip extends StatelessWidget {
  final String label;
  const _DataChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorFondo,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(color: colorTextoSuave, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
