import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../modelos/animal.dart';
import '../../tema.dart';
import '../../providers/adopciones_provider.dart';
import '../../providers/auth_provider.dart';

class AnimalDetalleScreen extends ConsumerStatefulWidget {
  final Animal animal;

  const AnimalDetalleScreen({
    super.key,
    required this.animal,
  });

  @override
  ConsumerState<AnimalDetalleScreen> createState() => _AnimalDetalleScreenState();
}

class _AnimalDetalleScreenState extends ConsumerState<AnimalDetalleScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _mostrarBottomSheetAdopcion() {
    final yaTiene = ref.read(adopcionesProvider).solicitudes.any((s) => s.idAnimal == widget.animal.id);
    if (yaTiene) return;

    final comentarioCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: colorBlanco,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Solicitar Adopción',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Cuéntanos por qué quieres adoptar a ${widget.animal.nombre}',
                style: const TextStyle(color: colorTextoSuave),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: comentarioCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Escribe aquí tu motivación...',
                  filled: true,
                  fillColor: colorFondo,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  if (ref.read(adopcionesProvider).solicitudes.any((s) => s.idAnimal == widget.animal.id)) {
                    if (!sheetContext.mounted) return;
                    Navigator.pop(sheetContext);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ya tienes una solicitud de adopción para este animal.'),
                        backgroundColor: colorTexto,
                      ),
                    );
                    return;
                  }
                  final exito = await ref.read(adopcionesProvider.notifier).crearSolicitud(
                    idAnimal: widget.animal.id,
                    comentarios: comentarioCtrl.text,
                  );
                  if (!sheetContext.mounted) return;
                  if (exito) {
                    Navigator.pop(sheetContext);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          '¡Solicitud enviada con éxito!',
                          style: TextStyle(color: colorBlanco, fontWeight: FontWeight.w600),
                        ),
                        backgroundColor: colorPrimario,
                      ),
                    );
                  } else {
                    if (!mounted) return;
                    final duplicado = ref.read(adopcionesProvider).solicitudes.any((s) => s.idAnimal == widget.animal.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          duplicado
                              ? 'Ya tienes una solicitud de adopción para este animal.'
                              : 'No se pudo enviar la solicitud. Inténtalo de nuevo.',
                        ),
                        backgroundColor: duplicado ? colorTexto : colorError,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorPrimario,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Confirmar Solicitud', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final esAdmin = authState.usuarioActual?.rol == 'Admin';
    final solicitudes = ref.watch(adopcionesProvider).solicitudes;
    final yaSolicitado = solicitudes.any((s) => s.idAnimal == widget.animal.id);
    
    // Lista de imágenes (usamos la principal + las de la galería si existen)
    final listaImagenes = [widget.animal.imagenUrl, ...widget.animal.imagenes];

    return Scaffold(
      backgroundColor: colorFondo,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Cabecera con Galería/Imagen
              SliverAppBar(
                expandedHeight: 450,
                pinned: true,
                leading: const SizedBox.shrink(),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      Hero(
                        tag: 'animal_${widget.animal.id}',
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (idx) => setState(() => _currentPage = idx),
                          itemCount: listaImagenes.length,
                          itemBuilder: (context, index) => Image.network(
                            listaImagenes[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Indicadores de puntos
                      if (listaImagenes.length > 1)
                        Positioned(
                          bottom: 40,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              listaImagenes.length,
                              (index) => Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: _currentPage == index ? 24 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _currentPage == index ? colorBlanco : colorBlanco.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                      // Gradiente para visibilidad
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black38, Colors.transparent, Colors.transparent, Colors.black26],
                            stops: [0.0, 0.2, 0.8, 1.0],
                          ),
                        ),
                        child: SizedBox.expand(),
                      ),
                    ],
                  ),
                ),
              ),

              // Información del animal
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: colorBlanco,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  transform: Matrix4.translationValues(0, -30, 0),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.animal.nombre,
                                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${widget.animal.especie} • ${widget.animal.raza}',
                                  style: const TextStyle(color: colorTextoSuave, fontSize: 16),
                                ),
                              ],
                            ),
                            _StatusBadge(label: widget.animal.estado),
                          ],
                        ),
                        const SizedBox(height: 32),
                        
                        // Chips de info rápida
                        Row(
                          children: [
                            _InfoChip(icon: Icons.cake_outlined, label: '${widget.animal.edad} años'),
                            const SizedBox(width: 12),
                            _InfoChip(icon: Icons.transgender_rounded, label: widget.animal.sexo),
                            const SizedBox(width: 12),
                            _InfoChip(icon: Icons.monitor_weight_outlined, label: widget.animal.peso),
                          ],
                        ),

                        const SizedBox(height: 32),
                        Text(
                          'Sobre ${widget.animal.nombre}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.animal.descripcion,
                          style: const TextStyle(color: colorTextoSuave, fontSize: 16, height: 1.6),
                        ),

                        const SizedBox(height: 32),
                        const Text(
                          'Salud y cuidados',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _HealthItem(label: 'Vacunación', value: widget.animal.vacunado),
                        _HealthItem(label: 'Esterilizado', value: widget.animal.esterilizado),
                        _HealthItem(label: 'Microchip', value: widget.animal.microchip),

                        const SizedBox(height: 32),
                        const Text(
                          'Ubicación',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colorFondo,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on_rounded, color: colorPrimario),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(widget.animal.refugio, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text(widget.animal.ubicacionRefugio, style: const TextStyle(color: colorTextoSuave, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 120), // Espacio para el botón inferior
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Botón de volver fijo
          Positioned(
            top: 20,
            left: 20,
            child: SafeArea(
              child: FloatingActionButton.small(
                onPressed: () => context.pop(),
                backgroundColor: Colors.white,
                foregroundColor: colorTexto,
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              ),
            ),
          ),

          // Botón de acción inferior fijo
          if (widget.animal.estado == 'Disponible')
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [colorBlanco.withValues(alpha: 0), colorBlanco],
                    stops: const [0.0, 0.3],
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: esAdmin
                      ? ElevatedButton.icon(
                          onPressed: () {
                            // En una fase posterior se abriría el diálogo de edición
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Función de edición próximamente')),
                            );
                          },
                          icon: const Icon(Icons.edit_rounded),
                          label: const Text('Editar Animal'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorPrimario,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: yaSolicitado ? null : _mostrarBottomSheetAdopcion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorPrimario,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            yaSolicitado ? 'Solicitud Enviada' : 'Solicitar Adopción',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorFondo,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: colorPrimario, size: 18),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}

class _HealthItem extends StatelessWidget {
  final String label;
  final bool value;
  const _HealthItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: value ? colorPrimario : Colors.grey[300],
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: colorTexto)),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  const _StatusBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorPrimarioLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(color: colorPrimario, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1),
      ),
    );
  }
}
