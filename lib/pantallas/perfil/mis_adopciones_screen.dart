import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../tema.dart';
import '../../modelos/animal.dart';
import '../../datos/favoritos_manager.dart';
import '../../datos/solicitudes_manager.dart';
// Pantalla para ver que animales hemos solicitado y cuales tenemos guardados
class MisAdopcionesScreen extends StatefulWidget {
  const MisAdopcionesScreen({super.key});

  @override
  State<MisAdopcionesScreen> createState() => _MisAdopcionesScreenState();
}

class _MisAdopcionesScreenState extends State<MisAdopcionesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Solicitud> _solicitudes;
  late List<Animal> _favoritos;

  @override
  void initState() {
    super.initState();
    // Iniciamos el tab controller para las dos pestañas
    _tabController = TabController(length: 2, vsync: this);
    _solicitudes = List.from(SolicitudesManager().solicitudes);
    _favoritos = List.from(FavoritosManager().favoritos);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Borrar solicitud
  void _eliminarSolicitud(Solicitud s) {
    SolicitudesManager().eliminar(s.id);
    setState(() => _solicitudes.removeWhere((x) => x.id == s.id));
  }

  // Borrar de favoritos
  void _eliminarFavorito(Animal animal) {
    FavoritosManager().toggleFavorito(animal);
    setState(() => _favoritos.removeWhere((a) => a.id == animal.id));
  }

  // Abrir detalle y refrescar al volver
  void _abrirDetalle(Animal animal) {
    context.push('/animal/${animal.id}', extra: animal).then((_) {
      setState(() {
        _solicitudes = List.from(SolicitudesManager().solicitudes);
        _favoritos = List.from(FavoritosManager().favoritos);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final esModoOscuro = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colores.surface,
      appBar: AppBar(
        title: const Text('Mis adopciones'),
        centerTitle: true,
        backgroundColor: colorPrimario,
        foregroundColor: colorBlanco,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/perfil'),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              color: colores.surface,
              border: Border(
                bottom: BorderSide(
                  color: colores.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: colorPrimario,
              unselectedLabelColor: colores.onSurfaceVariant,
              indicatorColor: colorPrimario,
              indicatorWeight: 2.5,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 13),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.send_outlined, size: 16),
                      const SizedBox(width: 6),
                      const Text('Solicitudes'),
                      if (_solicitudes.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        _badgeContador(_solicitudes.length),
                      ],
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.favorite_border, size: 16),
                      const SizedBox(width: 6),
                      const Text('Guardados'),
                      if (_favoritos.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        _badgeContador(_favoritos.length),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _pestanaSolicitudes(colores, esModoOscuro),
          _pestanaGuardados(colores, esModoOscuro),
        ],
      ),
    );
  }

  // El circulito con el numero de elementos
  Widget _badgeContador(int n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: colorPrimario.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$n',
        style: const TextStyle(fontSize: 11, color: colorPrimario, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Lista de solicitudes
  Widget _pestanaSolicitudes(ColorScheme colores, bool esModoOscuro) {
    if (_solicitudes.isEmpty) {
      return _mensajeVacio(
        colores: colores,
        icono: Icons.send_outlined,
        titulo: 'Todavia no tienes solicitudes',
        subtitulo: 'Pulsa "Solicitar adopcion" en la ficha de un animal',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _solicitudes.length,
      itemBuilder: (context, i) {
        final s = _solicitudes[i];
        return _TarjetaSolicitud(
          solicitud: s,
          esModoOscuro: esModoOscuro,
          onTap: () => _abrirDetalle(s.animal),
          onEliminar: () => _confirmarEliminarSolicitud(context, s),
        );
      },
    );
  }

  // Lista de favoritos
  Widget _pestanaGuardados(ColorScheme colores, bool esModoOscuro) {
    if (_favoritos.isEmpty) {
      return _mensajeVacio(
        colores: colores,
        icono: Icons.favorite_border,
        titulo: 'Todavia no tienes animales guardados',
        subtitulo: 'Pulsa el corazon en la ficha de un animal para guardarlo aqui',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _favoritos.length,
      itemBuilder: (context, i) {
        final animal = _favoritos[i];
        return _TarjetaFavorito(
          animal: animal,
          esModoOscuro: esModoOscuro,
          onEliminar: () => _confirmarEliminarFavorito(context, animal),
          onTap: () => _abrirDetalle(animal),
        );
      },
    );
  }

  // Popup de confirmar borrar solicitud
  void _confirmarEliminarSolicitud(BuildContext context, Solicitud s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancelar solicitud',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        content: Text(
          'Quieres cancelar la solicitud de ${s.animal.nombre}?',
          style: const TextStyle(fontSize: 14, color: colorTextoSuave),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          _filaBotonesDialogo(
            ctx: ctx,
            textoConfirmar: 'Cancelar solicitud',
            onConfirmar: () {
              Navigator.pop(ctx);
              _eliminarSolicitud(s);
            },
          )
        ],
      ),
    );
  }

  // Popup de confirmar borrar favorito
  void _confirmarEliminarFavorito(BuildContext context, Animal animal) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar guardado',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        content: Text(
          'Quieres eliminar a ${animal.nombre} de tus guardados?',
          style: const TextStyle(fontSize: 14, color: colorTextoSuave),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          _filaBotonesDialogo(
            ctx: ctx,
            textoConfirmar: 'Eliminar',
            onConfirmar: () {
              Navigator.pop(ctx);
              _eliminarFavorito(animal);
            },
          )
        ],
      ),
    );
  }

  // Widget para los botones de los dialogos (para no repetir codigo)
  Widget _filaBotonesDialogo({
    required BuildContext ctx,
    required String textoConfirmar,
    required VoidCallback onConfirmar,
  }) {
    return Row(children: [
      Expanded(
        child: OutlinedButton(
          onPressed: () => Navigator.pop(ctx),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Volver', style: TextStyle(color: colorTexto)),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: ElevatedButton(
          onPressed: onConfirmar,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorError,
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(textoConfirmar, style: const TextStyle(color: colorBlanco)),
        ),
      ),
    ]);
  }

  // El texto que sale cuando no hay nada en la lista
  Widget _mensajeVacio({
    required ColorScheme colores,
    required IconData icono,
    required String titulo,
    required String subtitulo,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 56, color: colores.onSurfaceVariant.withValues(alpha: 0.35)),
            const SizedBox(height: 16),
            Text(titulo,
                style: TextStyle(color: colores.onSurfaceVariant, fontSize: 15),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitulo,
                style: TextStyle(
                    color: colores.onSurfaceVariant.withValues(alpha: 0.6), fontSize: 13),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// Fondo rojo para el Slidable/Dismissible
Widget _fondoSlideBorrar(String texto) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(color: colorError, borderRadius: BorderRadius.circular(16)),
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.only(right: 24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.delete_outline, color: colorBlanco, size: 26),
        const SizedBox(height: 4),
        Text(texto, style: const TextStyle(color: colorBlanco, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

// Tarjeta de la solicitud
class _TarjetaSolicitud extends StatelessWidget {
  final Solicitud solicitud;
  final bool esModoOscuro;
  final VoidCallback onTap;
  final VoidCallback onEliminar;

  const _TarjetaSolicitud({
    required this.solicitud,
    required this.esModoOscuro,
    required this.onTap,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final estilo = _estiloEstado(solicitud.estado);

    return Dismissible(
      key: ValueKey('sol_${solicitud.id}'),
      direction: DismissDirection.endToStart,
      background: _fondoSlideBorrar('Cancelar'),
      confirmDismiss: (_) async {
        onEliminar();
        return false;
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: esModoOscuro ? colores.surfaceContainerHighest : colorBlanco,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: esModoOscuro ? 0.3 : 0.06),
                blurRadius: esModoOscuro ? 10 : 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Row(children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
              child: Image.network(
                solicitud.animal.imagenUrl,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 90, height: 90, color: const Color(0xFFE0F2F1),
                  child: const Icon(Icons.pets, color: colorPrimario),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(solicitud.animal.nombre,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colores.onSurface)),
                  Text(solicitud.animal.raza,
                      style: TextStyle(color: colores.onSurfaceVariant, fontSize: 13)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: estilo.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(estilo.icono, color: estilo.color, size: 13),
                      const SizedBox(width: 5),
                      Text(estilo.texto,
                          style: TextStyle(color: estilo.color, fontSize: 12, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(Icons.chevron_right, color: colores.onSurfaceVariant.withValues(alpha: 0.5), size: 20),
            ),
          ]),
        ),
      ),
    );
  }

  _EstiloEstado _estiloEstado(EstadoSolicitud estado) {
    switch (estado) {
      case EstadoSolicitud.aceptada:
        return const _EstiloEstado(color: colorReportar, icono: Icons.check_circle, texto: 'Aceptada');
      case EstadoSolicitud.rechazada:
        return const _EstiloEstado(color: colorError, icono: Icons.cancel, texto: 'Rechazada');
      case EstadoSolicitud.pendiente:
        return const _EstiloEstado(color: colorPerdidas, icono: Icons.hourglass_empty, texto: 'En espera');
    }
  }
}

class _EstiloEstado {
  final Color color; final IconData icono; final String texto;
  const _EstiloEstado({required this.color, required this.icono, required this.texto});
}

// Tarjeta de animal guardado
class _TarjetaFavorito extends StatelessWidget {
  final Animal animal;
  final bool esModoOscuro;
  final VoidCallback onEliminar;
  final VoidCallback onTap;

  const _TarjetaFavorito({
    required this.animal,
    required this.esModoOscuro,
    required this.onEliminar,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey('fav_${animal.id}'),
      direction: DismissDirection.endToStart,
      background: _fondoSlideBorrar('Eliminar'),
      confirmDismiss: (_) async {
        onEliminar();
        return false;
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: esModoOscuro ? colores.surfaceContainerHighest : colorBlanco,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: esModoOscuro ? 0.3 : 0.06),
                blurRadius: esModoOscuro ? 10 : 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Row(children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
              child: Image.network(
                animal.imagenUrl,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 90, height: 90, color: const Color(0xFFE0F2F1),
                  child: const Icon(Icons.pets, color: colorPrimario),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(animal.nombre,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colores.onSurface)),
                  Text(animal.raza,
                      style: TextStyle(color: colores.onSurfaceVariant, fontSize: 13)),
                  const SizedBox(height: 6),
                  Row(children: [
                    _chipInfo('${animal.edad} ${animal.edad == 1 ? 'anio' : 'anios'}', colores),
                    const SizedBox(width: 6),
                    _chipInfo(animal.sexo, colores),
                  ]),
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(Icons.chevron_right, color: colores.onSurfaceVariant.withValues(alpha: 0.5), size: 20),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _chipInfo(String label, ColorScheme colores) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: esModoOscuro ? colores.surface : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              color: esModoOscuro ? colores.onSurface : const Color(0xFF555555))),
    );
  }
}