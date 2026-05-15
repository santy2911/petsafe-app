import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../tema.dart';
import '../../modelos/animal.dart';
import '../../providers/animales_provider.dart';
import '../../widgets/boton_notificaciones.dart';

class AdminAnimalesScreen extends ConsumerStatefulWidget {
  const AdminAnimalesScreen({super.key});

  @override
  ConsumerState<AdminAnimalesScreen> createState() => _AdminAnimalesScreenState();
}

class _AdminAnimalesScreenState extends ConsumerState<AdminAnimalesScreen> {
  String filtro = '';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(animalesProvider);
    final animalesFiltrados = state.animales
        .where((a) => a.nombre.toLowerCase().contains(filtro.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        title: const Text('Gestión de Animales'),
        actions: [
          const BotonNotificaciones(),
          const SizedBox(width: 8),
          IconButton(
            onPressed: state.cargando ? null : () => ref.read(animalesProvider.notifier).recargar(),
            icon: state.cargando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: colorPrimario),
                  )
                : const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => _mostrarDialogoAnimal(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Añadir Animal'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              onChanged: (val) => setState(() => filtro = val),
              decoration: const InputDecoration(
                hintText: 'Buscar por nombre...',
                prefixIcon: Icon(Icons.search, color: colorTextoSuave),
              ),
            ),
            const SizedBox(height: 16),
            if (state.cargando && state.animales.isEmpty)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (state.error != null)
              Expanded(child: Center(child: Text('Error: ${state.error}')))
            else
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: Container(
                        width: double.infinity,
                        decoration: decorationSuperficieLista(),
                        clipBehavior: Clip.antiAlias,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minWidth: constraints.maxWidth),
                            child: DataTable(
                              columnSpacing: 24,
                              horizontalMargin: 16,
                              headingRowColor: WidgetStateProperty.all(colorFondo),
                              columns: const [
                                DataColumn(label: Text('Foto', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Nombre', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Especie', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Edad', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: animalesFiltrados.map((animal) {
                                return DataRow(cells: [
                                  DataCell(
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          animal.imagenUrl,
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => const Icon(Icons.pets),
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(Text(animal.nombre)),
                                  DataCell(Text(animal.especie)),
                                  DataCell(Text('${animal.edad} años')),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: animal.estado == 'Disponible'
                                            ? colorPrimarioLight
                                            : colorFondo,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        animal.estado,
                                        style: TextStyle(
                                          color: animal.estado == 'Disponible' ? colorPrimario : colorTextoSuave,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, color: colorPrimario, size: 20),
                                          onPressed: () => _mostrarDialogoAnimal(context, animal: animal),
                                          tooltip: 'Editar',
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.no_accounts_outlined, color: colorTextoSuave, size: 20),
                                          onPressed: () => _mostrarOpcionesBaja(context, animal),
                                          tooltip: 'Dar de baja',
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: colorError, size: 20),
                                          onPressed: () => _confirmarEliminarFisico(context, animal),
                                          tooltip: 'Eliminar permanentemente',
                                        ),
                                      ],
                                    ),
                                  ),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _mostrarOpcionesBaja(BuildContext context, Animal animal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Dar de baja a ${animal.nombre}'),
        content: const Text('Selecciona el motivo de la baja del sistema (borrado lógico):'),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(animalesProvider.notifier).darDeBaja(animal.id, 'Adoptado');
              Navigator.pop(context);
            },
            child: const Text('Por Adopción'),
          ),
          TextButton(
            onPressed: () {
              ref.read(animalesProvider.notifier).darDeBaja(animal.id, 'Fallecido');
              Navigator.pop(context);
            },
            child: const Text('Por Fallecimiento', style: TextStyle(color: colorTextoSuave)),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ],
      ),
    );
  }

  void _confirmarEliminarFisico(BuildContext context, Animal animal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Permanentemente'),
        content: Text('¿Estás seguro de que quieres eliminar a ${animal.nombre} de la base de datos? Esta acción es física e irreversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              ref.read(animalesProvider.notifier).eliminarAnimal(animal.id);
              Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: colorError)),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoAnimal(BuildContext context, {Animal? animal}) {
    final nombreCtrl = TextEditingController(text: animal?.nombre);
    final edadCtrl = TextEditingController(text: animal?.edad.toString());
    final descCtrl = TextEditingController(text: animal?.descripcion);
    String especie = animal?.especie ?? 'Perro';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(animal == null ? 'Añadir nuevo animal' : 'Editar animal'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nombreCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: edadCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Edad'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: especie,
                    items: const [
                      DropdownMenuItem(value: 'Perro', child: Text('Perro')),
                      DropdownMenuItem(value: 'Gato', child: Text('Gato')),
                    ],
                    onChanged: (val) => setDialogState(() => especie = val!),
                    decoration: const InputDecoration(labelText: 'Especie'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final nuevo = Animal(
                  id: animal?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  nombre: nombreCtrl.text,
                  edad: int.tryParse(edadCtrl.text) ?? 0,
                  especie: especie,
                  descripcion: descCtrl.text,
                  imagenUrl: animal?.imagenUrl ?? 'https://images.unsplash.com/photo-1552053831-71594a27632d?w=400',
                  raza: animal?.raza ?? 'Mestizo',
                  sexo: animal?.sexo ?? 'Macho',
                  disponible: animal?.disponible ?? true,
                  peso: animal?.peso ?? '10 kg',
                  vacunado: animal?.vacunado ?? true,
                  esterilizado: animal?.esterilizado ?? true,
                  microchip: animal?.microchip ?? true,
                  refugio: animal?.refugio ?? 'Refugio PetSafe',
                  ubicacionRefugio: animal?.ubicacionRefugio ?? 'Madrid, España',
                  estado: animal?.estado ?? 'Disponible',
                );

                if (animal == null) {
                  await ref.read(animalesProvider.notifier).agregarAnimal(nuevo);
                } else {
                  await ref.read(animalesProvider.notifier).editarAnimal(nuevo);
                }

                if (mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(120, 40)),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
