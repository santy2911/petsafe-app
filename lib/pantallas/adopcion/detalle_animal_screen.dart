import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../modelos/animal.dart';
import '../../tema.dart';
import '../../datos/favoritos_manager.dart';
import '../../datos/solicitudes_manager.dart';
import '../../providers/estadisticas_provider.dart';

// Pantalla con el detalle del animal
class DetalleAnimalScreen extends ConsumerStatefulWidget {
  final Animal animal;
  final String origenRuta;
  final bool usarPop;

  const DetalleAnimalScreen({
    super.key,
    required this.animal,
    this.origenRuta = '/catalogo',
    this.usarPop = false,
  });

  @override
  ConsumerState<DetalleAnimalScreen> createState() =>
      _DetalleAnimalScreenState();
}

class _DetalleAnimalScreenState extends ConsumerState<DetalleAnimalScreen> {
  late bool _esFavorito;

  @override
  void initState() {
    super.initState();
    _esFavorito = FavoritosManager().esFavorito(widget.animal.id);
  }

  // Guarda o quita el animal de favoritos
  void _toggleFavorito() {
    final agregado = FavoritosManager().toggleFavorito(widget.animal);
    setState(() => _esFavorito = agregado);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              agregado ? Icons.favorite : Icons.favorite_border,
              color: colorBlanco,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                agregado
                    ? '${widget.animal.nombre} guardado — puedes verlo en Perfil > Mis adopciones'
                    : '${widget.animal.nombre} eliminado de Mis adopciones',
                style: const TextStyle(color: colorBlanco, fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: agregado ? colorPrimario : colorTextoSuave,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colores.surface,
      body: CustomScrollView(
        slivers: [
          _appBarDetalle(context, colores),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _tarjetaDatos(colores),
                  const SizedBox(height: 20),
                  _seccionDescripcion(colores),
                  const SizedBox(height: 20),
                  _seccionSalud(colores),
                  const SizedBox(height: 20),
                  _tarjetaRefugio(colores),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _barraAdopcion(context, colores),
    );
  }

  // Appbar con la foto del animal
  SliverAppBar _appBarDetalle(BuildContext context, ColorScheme colores) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: colorPrimario,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: colorBlanco,
          size: 20,
        ),
        onPressed: () {
          if (widget.usarPop) {
            Navigator.of(context).pop();
          } else {
            context.go(widget.origenRuta);
          }
        },
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: IconButton(
              key: ValueKey(_esFavorito),
              icon: Icon(
                _esFavorito ? Icons.favorite : Icons.favorite_border,
                color: _esFavorito ? Colors.red.shade300 : colorBlanco,
                size: 26,
              ),
              onPressed: _toggleFavorito,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              widget.animal.imagenUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: colorAcento,
                child: const Icon(Icons.pets, size: 80, color: colorPrimario),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                  stops: [0.5, 1.0],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.animal.nombre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.animal.raza,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _badgeEstado(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Muestra si esta disponible
  Widget _badgeEstado() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: widget.animal.disponible ? colorPrimario : Colors.grey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        widget.animal.disponible ? 'Disponible' : 'Adoptado',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Datos principales del animal
  Widget _tarjetaDatos(ColorScheme colores) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: _decoracionTarjeta(16, colores),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _InfoItem(
            icono: Icons.cake_outlined,
            label: 'Edad',
            valor:
                '${widget.animal.edad} ${widget.animal.edad == 1 ? 'anio' : 'anios'}',
            colores: colores,
          ),
          _divider(colores),
          _InfoItem(
            icono: Icons.transgender,
            label: 'Genero',
            valor: widget.animal.sexo,
            colores: colores,
          ),
          _divider(colores),
          _InfoItem(
            icono: Icons.monitor_weight_outlined,
            label: 'Peso',
            valor: widget.animal.peso,
            colores: colores,
          ),
        ],
      ),
    );
  }

  // Descripcion del animal
  Widget _seccionDescripcion(ColorScheme colores) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descripcion',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: colores.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.animal.descripcion,
          style: TextStyle(
            color: colores.onSurfaceVariant,
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  // Datos de salud
  Widget _seccionSalud(ColorScheme colores) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estado de salud',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: colores.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        _SaludItem(
          label: 'Vacunado',
          valor: widget.animal.vacunado,
          colores: colores,
        ),
        const SizedBox(height: 8),
        _SaludItem(
          label: 'Esterilizado',
          valor: widget.animal.esterilizado,
          colores: colores,
        ),
        const SizedBox(height: 8),
        _SaludItem(
          label: 'Microchip',
          valor: widget.animal.microchip,
          colores: colores,
        ),
      ],
    );
  }

  // Datos del refugio
  Widget _tarjetaRefugio(ColorScheme colores) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _decoracionTarjeta(14, colores),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorPrimario.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.home_outlined,
              color: colorPrimario,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Refugio',
                style: TextStyle(fontSize: 11, color: colores.onSurfaceVariant),
              ),
              Text(
                widget.animal.refugio,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colores.onSurface,
                ),
              ),
              Text(
                widget.animal.ubicacionRefugio,
                style: TextStyle(fontSize: 12, color: colores.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Barra inferior de adopcion
  Widget _barraAdopcion(BuildContext context, ColorScheme colores) {
    final yaSolicitado = SolicitudesManager().tieneSolicitud(widget.animal.id);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: colores.surfaceContainer,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: yaSolicitado
            ? null
            : () => _mostrarDialogoAdopcion(context, colores),
        icon: Icon(yaSolicitado ? Icons.check : Icons.favorite, size: 18),
        label: Text(yaSolicitado ? 'Solicitud enviada' : 'Solicitar adopcion'),
        style: ElevatedButton.styleFrom(
          backgroundColor: yaSolicitado ? colorTextoSuave : colorPrimario,
          foregroundColor: colorBlanco,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // Dialogo para confirmar
  void _mostrarDialogoAdopcion(BuildContext context, ColorScheme colores) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colores.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'Solicitar adopcion de ${widget.animal.nombre}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colores.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  color: colores.onSurfaceVariant,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: 'Al confirmar, el refugio '),
                  TextSpan(
                    text: widget.animal.refugio,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colores.onSurface,
                    ),
                  ),
                  const TextSpan(
                    text:
                        ' recibira tu solicitud y se pondra en contacto contigo.',
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: colores.outline),
                  ),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: colores.onSurface),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    // Guarda la solicitud en el manager
                    SolicitudesManager().agregar(widget.animal);
                    // Suma estadistica
                    ref.read(estadisticasProvider.notifier).sumarAdopcion();
                    // Refresca el boton
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: const [
                            Icon(
                              Icons.check_circle_outline,
                              color: colorBlanco,
                              size: 18,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Solicitud enviada — puedes verla en Perfil > Mis adopciones',
                                style: TextStyle(
                                  color: colorBlanco,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: colorAdoptar,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: EdgeInsets.all(16),
                        duration: Duration(seconds: 4),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Confirmar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorPrimario,
                    foregroundColor: colorBlanco,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Estilo de tarjetas
  BoxDecoration _decoracionTarjeta(double radio, ColorScheme colores) {
    return BoxDecoration(
      color: colores.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(radio),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // Separador simple
  Widget _divider(ColorScheme colores) {
    return Container(width: 1, height: 40, color: colores.outlineVariant);
  }
}

// Item de informacion
class _InfoItem extends StatelessWidget {
  final IconData icono;
  final String label;
  final String valor;
  final ColorScheme colores;

  const _InfoItem({
    required this.icono,
    required this.label,
    required this.valor,
    required this.colores,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icono, color: colorPrimario, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: colores.onSurfaceVariant, fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          valor,
          style: TextStyle(
            color: colores.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

// Item de salud
class _SaludItem extends StatelessWidget {
  final String label;
  final bool valor;
  final ColorScheme colores;

  const _SaludItem({
    required this.label,
    required this.valor,
    required this.colores,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.circle_outlined,
              size: 14,
              color: colores.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(fontSize: 14, color: colores.onSurface),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          decoration: BoxDecoration(
            color: valor
                ? const Color(0xFF2E7D32).withValues(alpha: 0.15)
                : const Color(0xFFC62828).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            valor ? 'Si' : 'No',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: valor ? const Color(0xFF4CAF50) : const Color(0xFFEF5350),
            ),
          ),
        ),
      ],
    );
  }
}
