import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../modelos/reporte.dart';
import '../../providers/reportes_provider.dart';
import '../../tema.dart';
import '../../widgets/navbar.dart';

// Pantalla del mapa de mascotas perdidas
class MapaScreen extends ConsumerStatefulWidget {
  final Reporte? reporteInicial;

  const MapaScreen({super.key, this.reporteInicial});

  @override
  ConsumerState<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends ConsumerState<MapaScreen> {
  late final MapController _mapController;
  bool _vistaLista = false;
  LatLngBounds? _boundsActuales;
  bool _mapaListo = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _mapaListo = true);

      if (widget.reporteInicial != null) {
        _mapController.move(
          LatLng(widget.reporteInicial!.latitud, widget.reporteInicial!.longitud),
          16.0,
        );
        _mostrarDetalleReporte(context, widget.reporteInicial!);
      }
    });
  }

  // Filtra los reportes que se ven en el mapa
  List<Reporte> _reportesVisibles(List<Reporte> todos) {
    if (!_mapaListo) return todos;
    final bounds = _boundsActuales;
    if (bounds == null) {
      try {
        return todos.where((r) {
          return _mapController.camera.visibleBounds
              .contains(LatLng(r.latitud, r.longitud));
        }).toList();
      } catch (_) {
        return todos;
      }
    }
    return todos.where((r) {
      return bounds.contains(LatLng(r.latitud, r.longitud));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final reportes = ref.watch(reportesProvider).reportes;
    final visibles = _reportesVisibles(reportes);

    return Scaffold(
      backgroundColor: colores.surface,
      bottomNavigationBar: const NavbarPrincipal(indiceActual: 1),
      body: Stack(
        children: [
          _mapa(context, reportes),
          if (_vistaLista)
            _vistaListaWidget(context, visibles),
          _cabecera(context, visibles.length),
          if (!_vistaLista)
            _leyendaMapa(context),
          if (!_vistaLista)
            _botonNuevoReporte(context),
        ],
      ),
    );
  }

  // Cabecera del mapa
  Widget _cabecera(BuildContext context, int count) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 12,
          left: 16,
          right: 16,
          bottom: 12,
        ),
        decoration: BoxDecoration(
          color: colorPrimario,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Mascotas perdidas',
              style: TextStyle(
                color: colorBlanco,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$count ${count == 1 ? 'alerta activa' : 'alertas activas'} en tu zona',
              style: TextStyle(
                color: colorBlanco.withValues(alpha: 0.85),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 10),
            _toggleMapaLista(),
          ],
        ),
      ),
    );
  }

  // Cambia entre mapa y lista
  Widget _toggleMapaLista() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _botonToggle(
            icono: Icons.map_outlined,
            label: 'Mapa',
            activo: !_vistaLista,
            onTap: () => setState(() => _vistaLista = false),
          ),
          _botonToggle(
            icono: Icons.list_outlined,
            label: 'Lista',
            activo: _vistaLista,
            onTap: () {
              LatLngBounds? bounds;
              try {
                bounds = _mapController.camera.visibleBounds;
              } catch (_) {
                bounds = null;
              }
              setState(() {
                _boundsActuales = bounds;
                _vistaLista = true;
              });
            },
          ),
        ],
      ),
    );
  }

  // Boton del selector superior
  Widget _botonToggle({
    required IconData icono,
    required String label,
    required bool activo,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: activo ? colorBlanco : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(icono, size: 16, color: activo ? colorPrimario : colorBlanco),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: activo ? colorPrimario : colorBlanco,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mapa con marcadores
  Widget _mapa(BuildContext context, List<Reporte> reportes) {
    final topPadding = MediaQuery.of(context).padding.top + 110.0;

    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: widget.reporteInicial != null
              ? LatLng(widget.reporteInicial!.latitud, widget.reporteInicial!.longitud)
              : const LatLng(40.4168, -3.7038),
          initialZoom: widget.reporteInicial != null ? 16.0 : 14.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.petsafe.app',
            additionalOptions: const {'User-Agent': 'PetSafe/1.0 (TFG DAM)'},
          ),
          MarkerLayer(
            markers: reportes
                .map((reporte) => _marcadorReporte(context, reporte))
                .toList(),
          ),
        ],
      ),
    );
  }

  // Marcador de cada reporte
  Marker _marcadorReporte(BuildContext context, Reporte reporte) {
    return Marker(
      point: LatLng(reporte.latitud, reporte.longitud),
      width: 40,
      height: 40,
      child: GestureDetector(
        onTap: () => _mostrarDetalleReporte(context, reporte),
        child: Icon(Icons.location_on, color: _colorReporte(reporte), size: 40),
      ),
    );
  }

  // Vista en lista
  Widget _vistaListaWidget(BuildContext context, List<Reporte> visibles) {
    final topPadding = MediaQuery.of(context).padding.top + 110.0;
    final colores = Theme.of(context).colorScheme;

    return Positioned.fill(
      top: topPadding,
      child: Container(
        color: colores.surface,
        child: Column(
          children: [
            Expanded(
              child: visibles.isEmpty
                  ? _listaVacia(context)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      itemCount: visibles.length,
                      itemBuilder: (_, i) => _tarjetaReporte(context, visibles[i]),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/reportar'),
                  icon: const Icon(Icons.add, color: colorBlanco),
                  label: const Text(
                    'Reportar mascota perdida',
                    style: TextStyle(color: colorBlanco, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorPrimario,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mensaje si no hay reportes
  Widget _listaVacia(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.pets, size: 56, color: colores.onSurfaceVariant.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text(
            'No hay reportes en esta zona',
            style: TextStyle(
              fontSize: 15,
              color: colores.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Mueve el mapa y vuelve a la lista',
            style: TextStyle(fontSize: 13, color: colores.onSurfaceVariant.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }

  // Tarjeta de un reporte
  Widget _tarjetaReporte(BuildContext context, Reporte reporte) {
    final colores = Theme.of(context).colorScheme;
    final esEncontrado = reporte.encontrado;
    final colorEstado = _colorReporte(reporte);

    return GestureDetector(
      onTap: () => _mostrarDetalleReporte(context, reporte),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: colores.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colores.outlineVariant.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              child: Image.network(
                reporte.imagenUrl,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 90,
                  height: 90,
                  color: const Color(0xFFEEEEEE),
                  child: const Icon(Icons.pets, size: 32, color: colorTextoSuave),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          reporte.nombre,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: colores.onSurface,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: colorEstado.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            esEncontrado ? 'ENCONTRADO' : 'PERDIDO',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: colorEstado,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      reporte.descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: colores.onSurfaceVariant),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 12, color: colores.onSurfaceVariant),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            reporte.direccion,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11, color: colores.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 12, color: colores.onSurfaceVariant),
                        const SizedBox(width: 3),
                        Text(
                          '${reporte.fecha.year}-${reporte.fecha.month.toString().padLeft(2, '0')}-${reporte.fecha.day.toString().padLeft(2, '0')}',
                          style: TextStyle(fontSize: 11, color: colores.onSurfaceVariant),
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.phone_outlined, size: 12, color: colorPrimario),
                        const SizedBox(width: 3),
                        Text(
                          reporte.telefono,
                          style: const TextStyle(fontSize: 11, color: colorPrimario),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Botones del mapa
  Widget _leyendaMapa(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final topCabecera = MediaQuery.of(context).padding.top + 120.0;

    return Positioned(
      top: topCabecera,
      left: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colores.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
            ),
          ],
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _PuntoLeyenda(color: colorPerdidas, label: 'Mascota perdida'),
            SizedBox(height: 6),
            _PuntoLeyenda(color: colorReportar, label: 'Mascota encontrada'),
          ],
        ),
      ),
    );
  }

  // Boton flotante para crear reporte
  Widget _botonNuevoReporte(BuildContext context) {
    return Positioned(
      bottom: 90,
      right: 16,
      child: FloatingActionButton.extended(
        onPressed: () => context.go('/reportar'),
        backgroundColor: colorAdoptar,
        icon: const Icon(Icons.add, color: colorBlanco),
        label: const Text(
          'Nuevo reporte',
          style: TextStyle(color: colorBlanco),
        ),
      ),
    );
  }

  // Detalle del reporte
  void _mostrarDetalleReporte(BuildContext context, Reporte reporte) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _contenidoReporte(context, reporte),
    );
  }

  // Contenido del modal
  Widget _contenidoReporte(BuildContext context, Reporte reporte) {
    final colores = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.55,
      maxChildSize: 0.65,
      expand: false,
      builder: (_, scrollController) => SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _imagenReporte(reporte),
            const SizedBox(height: 16),
            _tituloReporte(reporte),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.pets, size: 16, color: colores.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  '${reporte.nombre} · ${reporte.especie}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colores.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (reporte.raza.isNotEmpty)
              Text(
                reporte.raza,
                style: TextStyle(fontSize: 13, color: colores.onSurfaceVariant),
              ),
            const SizedBox(height: 10),
            Text(
              reporte.descripcion,
              style: TextStyle(color: colores.onSurface, fontSize: 14),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 14, color: colores.onSurfaceVariant),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    reporte.direccion,
                    style: TextStyle(color: colores.onSurfaceVariant, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 14, color: colores.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  '${reporte.fecha.day}/${reporte.fecha.month}/${reporte.fecha.year}',
                  style: TextStyle(fontSize: 13, color: colores.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.phone_outlined, size: 16),
                label: Text(reporte.telefono),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorPrimario,
                  side: const BorderSide(color: colorPrimario),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Imagen del reporte
  Widget _imagenReporte(Reporte reporte) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        reporte.imagenUrl,
        width: double.infinity,
        height: 160,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          width: double.infinity,
          height: 160,
          color: const Color(0xFFEEEEEE),
          child: const Icon(Icons.pets, size: 48, color: colorTextoSuave),
        ),
      ),
    );
  }

  // Titulo del estado del reporte
  Widget _tituloReporte(Reporte reporte) {
    return Row(
      children: [
        Icon(
          reporte.encontrado ? Icons.check_circle : Icons.location_on,
          color: _colorReporte(reporte),
          size: 28,
        ),
        const SizedBox(width: 8),
        Text(
          reporte.encontrado ? 'Encontrada' : 'Perdida',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _colorReporte(reporte),
          ),
        ),
      ],
    );
  }

  // Color segun el estado
  Color _colorReporte(Reporte reporte) {
    return reporte.encontrado ? colorReportar : colorPerdidas;
  }
}

// Punto de la leyenda
class _PuntoLeyenda extends StatelessWidget {
  final Color color;
  final String label;

  const _PuntoLeyenda({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
