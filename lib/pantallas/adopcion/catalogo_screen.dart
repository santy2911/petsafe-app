import 'package:flutter/material.dart';
import '../../tema.dart';
import '../../modelos/animal.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/navbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/animales_provider.dart';

// Pantalla del catalogo de animales en adopcion
class CatalogoScreen extends ConsumerStatefulWidget {
  const CatalogoScreen({super.key});

  @override
  ConsumerState<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends ConsumerState<CatalogoScreen> {
  final _busquedaController = TextEditingController();
  String _filtro = '';
  String _especieFiltro = 'Todos';
  String _edadFiltro = '';
  String _sexoFiltro = '';

  static const _edades = ['Cachorro', 'Adulto', 'Senior'];
  static const _sexos = ['Macho', 'Hembra'];

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  // Comprueba el filtro de edad
  bool _coincideEdad(int edad) {
    if (_edadFiltro == 'Cachorro') return edad < 2;
    if (_edadFiltro == 'Adulto') return edad >= 2 && edad <= 7;
    if (_edadFiltro == 'Senior') return edad > 7;
    return true;
  }

  // Lista filtrada para mostrar
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
      final coincideSexo = _sexoFiltro.isEmpty || a.sexo == _sexoFiltro;

      return coincideTexto &&
          coincideEspecie &&
          _coincideEdad(a.edad) &&
          coincideSexo;
    }).toList();
  }

  // Modal con filtros extra
  void _mostrarFiltros() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filtros',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Edad',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  _chipRow(
                    opciones: _edades,
                    seleccionado: _edadFiltro,
                    onSeleccionar: (v) => setModal(() => _edadFiltro = v),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sexo',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  _chipRow(
                    opciones: _sexos,
                    seleccionado: _sexoFiltro,
                    onSeleccionar: (v) => setModal(() => _sexoFiltro = v),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {});
                        Navigator.pop(ctx);
                      },
                      child: const Text('Aplicar filtros'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Chips reutilizados en el modal
  Widget _chipRow({
    required List<String> opciones,
    required String seleccionado,
    required void Function(String) onSeleccionar,
  }) {
    final esModoOscuro = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: 8,
      children: opciones.map((op) {
        final activo = seleccionado == op;
        return FilterChip(
          label: Text(op),
          selected: activo,
          onSelected: (_) => onSeleccionar(activo ? '' : op),
          selectedColor: colorPrimario,
          checkmarkColor: Colors.white,
          labelStyle: TextStyle(
            color: activo
                ? Colors.white
                : (esModoOscuro ? Colors.white70 : Colors.black87),
            fontSize: 13,
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final esModoOscuro = Theme.of(context).brightness == Brightness.dark;
    final animalesFiltrados = _animalesFiltrados;

    final colorBarraFiltros = colores.surface;

    return Scaffold(
      backgroundColor: colores.surface,
      bottomNavigationBar: const NavbarPrincipal(indiceActual: 0),
      body: Column(
        children: [
          // Cabecera con buscador
          Container(
            color: colorPrimario,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.go('/home'),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Catálogo de adopción',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${animalesFiltrados.length} animales disponibles',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _busquedaController,
                      onChanged: (v) => setState(() => _filtro = v),
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'Buscar por nombre o raza...',
                        hintStyle: const TextStyle(
                          color: Colors.black45,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.black45,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Barra de filtros
          Container(
            color: colorBarraFiltros,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _tabEspecie('Todos', Icons.pets, esModoOscuro),
                        const SizedBox(width: 8),
                        _tabEspecie('Perro', Icons.pets, esModoOscuro),
                        const SizedBox(width: 8),
                        _tabEspecie(
                          'Gato',
                          Icons.catching_pokemon,
                          esModoOscuro,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _mostrarFiltros,
                  icon: Icon(Icons.tune, size: 16, color: colores.onSurface),
                  label: Text(
                    'Filtrar',
                    style: TextStyle(color: colores.onSurface),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colores.onSurface,
                    side: BorderSide(
                      color: colores.outline.withValues(alpha: 0.4),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          // Lista de animales
          Expanded(
            child: animalesFiltrados.isEmpty
                ? Center(
                    child: Text(
                      'No se encontraron animales',
                      style: TextStyle(color: colores.onSurfaceVariant),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: animalesFiltrados.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) =>
                        _AnimalCardFigma(animal: animalesFiltrados[index]),
                  ),
          ),
        ],
      ),
    );
  }

  // Boton de filtro por especie
  Widget _tabEspecie(String label, IconData icon, bool esModoOscuro) {
    final activo = _especieFiltro == label;

    final colorInactivo = esModoOscuro
        ? const Color(0xFF2C2C2C)
        : const Color(0xFFF0F0F0);
    final colorTextoInactivo = esModoOscuro ? Colors.white70 : Colors.black87;
    final colorIconoInactivo = esModoOscuro ? Colors.white54 : Colors.black54;

    return GestureDetector(
      onTap: () => setState(() => _especieFiltro = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: activo ? colorPrimario : colorInactivo,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: activo ? Colors.white : colorIconoInactivo,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: activo ? Colors.white : colorTextoInactivo,
                fontSize: 13,
                fontWeight: activo ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Tarjeta de animal
class _AnimalCardFigma extends StatelessWidget {
  final Animal animal;
  const _AnimalCardFigma({required this.animal});

  static const _refugios = [
    'Refugio Esperanza Madrid',
    'Protectora Los Animales',
    'Refugio Esperanza Madrid',
    'Protectora Los Animales',
    'Refugio Esperanza Madrid',
  ];

  static const _pesos = ['28 kg', '3.5 kg', '4 kg', '32 kg', '8 kg'];

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final esModoOscuro = Theme.of(context).brightness == Brightness.dark;

    final idx = (int.tryParse(animal.id) ?? 1) - 1;
    final refugio = _refugios[idx % _refugios.length];
    final peso = _pesos[idx % _pesos.length];

    final colorTarjeta = esModoOscuro
        ? colores.surfaceContainerHighest
        : Colors.white;

    final sombra = esModoOscuro
        ? BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        : BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          );

    final borde = esModoOscuro
        ? Border.all(color: colores.outline.withValues(alpha: 0.2), width: 1)
        : null;

    final colorChip = esModoOscuro
        ? colores.surfaceContainerLowest
        : const Color(0xFFF0F0F0);

    final colorTextoChip = esModoOscuro
        ? Colors.white.withValues(alpha: 0.9)
        : const Color(0xFF555555);

    return GestureDetector(
      onTap: () => context.go('/animal/${animal.id}', extra: animal),
      child: Container(
        decoration: BoxDecoration(
          color: colorTarjeta,
          borderRadius: BorderRadius.circular(14),
          border: borde,
          boxShadow: [sombra],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
              child: Image.network(
                animal.imagenUrl,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 90,
                  height: 90,
                  color: esModoOscuro
                      ? colores.surfaceContainerLowest
                      : const Color(0xFFE0F2F1),
                  child: const Icon(Icons.pets, color: colorPrimario, size: 36),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          animal.nombre,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: colores.onSurface,
                          ),
                        ),
                        if (animal.disponible)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorPrimario,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Disponible',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      animal.raza,
                      style: TextStyle(
                        fontSize: 12,
                        color: colores.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: [
                        _chip('${animal.edad} ${animal.edad == 1 ? 'año' : 'años'}', colorChip, colorTextoChip),
                        _chip(animal.sexo, colorChip, colorTextoChip),
                        _chip(peso, colorChip, colorTextoChip),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 12,
                          color: colorPrimario,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            refugio,
                            style: TextStyle(
                              fontSize: 11,
                              color: colores.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(
                Icons.chevron_right,
                color: colores.onSurfaceVariant.withValues(alpha: 0.5),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Chip de datos del animal
  Widget _chip(String label, Color colorChip, Color colorTextoChip) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: colorChip,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: colorTextoChip),
      ),
    );
  }
}
