import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../modelos/reporte.dart';
import '../../providers/reportes_provider.dart';
import '../../tema.dart';
import '../../widgets/boton_notificaciones.dart';
import '../../widgets/estados_vistas.dart';

class MapaScreen extends ConsumerStatefulWidget {
  final Reporte? reporteInicial;

  const MapaScreen({super.key, this.reporteInicial});

  @override
  ConsumerState<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends ConsumerState<MapaScreen> {
  late final MapController _mapController;
  bool _vistaLista = true;
  Reporte? _reporteSeleccionado;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.reporteInicial != null) {
        _mapController.move(LatLng(widget.reporteInicial!.latitud, widget.reporteInicial!.longitud), 16.0);
        setState(() => _reporteSeleccionado = widget.reporteInicial);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportesState = ref.watch(reportesProvider);

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        title: const Text('Mascotas Perdidas'),
        actions: [
          const BotonNotificaciones(),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(
                  value: false, 
                  label: Text('Mapa', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)), 
                  icon: Icon(Icons.map_rounded, size: 18)
                ),
                ButtonSegment<bool>(
                  value: true, 
                  label: Text('Lista', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)), 
                  icon: Icon(Icons.view_list_rounded, size: 18)
                ),
              ],
              selected: {_vistaLista},
              onSelectionChanged: (newSelection) {
                setState(() => _vistaLista = newSelection.first);
              },
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                backgroundColor: Colors.transparent,
                selectedBackgroundColor: colorPrimario,
                selectedForegroundColor: Colors.white,
                side: BorderSide(color: colorPrimario.withValues(alpha: 0.5)),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _buildBody(reportesState),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/reportar'),
        icon: const Icon(Icons.add, color: colorBlanco),
        label: const Text('Reportar', style: TextStyle(color: colorBlanco)),
        backgroundColor: colorAdoptar,
      ),
    );
  }

  Widget _buildBody(ReportesState state) {
    if (state.cargando && state.reportes.isEmpty) return const LoadingStateWidget();
    if (state.error != null && state.reportes.isEmpty) {
      return ErrorStateWidget(mensaje: state.error!, onRetry: () => ref.read(reportesProvider.notifier).cargarReportes());
    }
    if (state.reportes.isEmpty && !_vistaLista) {
      return const EmptyStateWidget(icono: Icons.map_outlined, titulo: 'No hay reportes en el mapa', subtitulo: 'Sé el primero en avisar sobre una mascota perdida.');
    }

    return Stack(
      children: [
        _buildMap(state.reportes),
        if (_vistaLista) _buildListView(state.reportes),
        if (!_vistaLista) _buildLegend(),
        if (_reporteSeleccionado != null && !_vistaLista) _buildMarkerPopup(_reporteSeleccionado!),
      ],
    );
  }

  Widget _buildMap(List<Reporte> reportes) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: widget.reporteInicial != null ? LatLng(widget.reporteInicial!.latitud, widget.reporteInicial!.longitud) : const LatLng(40.4168, -3.7038),
        initialZoom: 14.0,
        onTap: (_, __) => setState(() => _reporteSeleccionado = null),
      ),
      children: [
        TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.petsafe.app'),
        MarkerLayer(
          markers: reportes.map((reporte) {
            final color = reporte.encontrado ? colorPrimario : colorAcento;
            final isSelected = _reporteSeleccionado?.id == reporte.id;
            return Marker(
              point: LatLng(reporte.latitud, reporte.longitud),
              width: isSelected ? 60 : 40, height: isSelected ? 60 : 40,
              child: GestureDetector(
                onTap: () {
                  setState(() => _reporteSeleccionado = reporte);
                  _mapController.move(LatLng(reporte.latitud, reporte.longitud), _mapController.camera.zoom);
                },
                child: AnimatedContainer(duration: const Duration(milliseconds: 200), child: Icon(isSelected ? Icons.location_history_rounded : Icons.location_on_rounded, color: color, size: isSelected ? 50 : 40)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMarkerPopup(Reporte reporte) {
    return Positioned(
      bottom: 24, left: 24, right: 24,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Card(
            elevation: 12, shadowColor: Colors.black45, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(children: [
                    ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network(reporte.imagenUrl, width: 80, height: 80, fit: BoxFit.cover)),
                    const SizedBox(width: 16),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _StatusBadge(label: reporte.encontrado ? 'ENCONTRADO' : 'PERDIDO', isEncontrado: reporte.encontrado),
                      const SizedBox(height: 8),
                      Text(reporte.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text(reporte.descripcion, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: colorTextoSuave, fontSize: 13)),
                    ])),
                    IconButton(onPressed: () => setState(() => _reporteSeleccionado = null), icon: const Icon(Icons.close_rounded, size: 20)),
                  ]),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: () => context.push('/reporte/${reporte.id}', extra: reporte), child: const Text('Ver Detalle Completo')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListView(List<Reporte> reportes) {
    return Container(
      color: colorFondo,
      child: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: reportes.length,
        itemBuilder: (context, i) {
          final reporte = reportes[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Card(
              surfaceTintColor: Colors.transparent,
              child: Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  splashFactory: NoSplash.splashFactory,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(reporte.imagenUrl, width: 60, height: 60, fit: BoxFit.cover)),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _StatusBadge(label: reporte.encontrado ? 'ENCONTRADO' : 'PERDIDO', isEncontrado: reporte.encontrado),
                      const SizedBox(height: 8),
                      Text(reporte.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(reporte.direccion),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF000000)),
                  onTap: () {
                    setState(() { _vistaLista = false; _reporteSeleccionado = reporte; });
                    _mapController.move(LatLng(reporte.latitud, reporte.longitud), 16.0);
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLegend() {
    return Positioned(
      top: 16, left: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: colorBlanco, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_LegendItem(color: colorAcento, label: 'Perdido'), const SizedBox(height: 8), _LegendItem(color: colorPrimario, label: 'Encontrado')]),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final bool isEncontrado;
  const _StatusBadge({required this.label, required this.isEncontrado});
  @override
  Widget build(BuildContext context) {
    final color = isEncontrado ? colorPrimario : colorAcento;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)));
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 8), Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))]);
  }
}
