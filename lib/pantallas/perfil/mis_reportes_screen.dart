import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../tema.dart';
import '../../modelos/reporte.dart';
import '../../providers/reportes_provider.dart';

// Pantalla con los reportes del usuario
class MisReportesScreen extends ConsumerStatefulWidget {
  const MisReportesScreen({super.key});

  @override
  ConsumerState<MisReportesScreen> createState() => _MisReportesScreenState();
}

class _MisReportesScreenState extends ConsumerState<MisReportesScreen> {
  void _marcarEncontrado(Reporte reporte) {
    ref.read(reportesProvider.notifier).marcarEncontrado(reporte.id);
    _mostrarMensaje('Mascota marcada como encontrada', colorReportar);
  }

  void _eliminarReporte(Reporte reporte) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar reporte'),
        content: const Text('Esta seguro de que quieres eliminar este reporte?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ref.read(reportesProvider.notifier).eliminar(reporte.id);
              Navigator.pop(ctx);
              _mostrarMensaje('Reporte eliminado', colorError);
            },
            child: const Text('Eliminar', style: TextStyle(color: colorError)),
          ),
        ],
      ),
    );
  }

  void _mostrarMensaje(String texto, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: color),
    );
  }

  void _mostrarDetalle(Reporte reporte) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _DetalleReporteSheet(
        reporte: reporte,
        onMarcarEncontrado: () {
          Navigator.pop(context);
          _marcarEncontrado(reporte);
        },
        onEditar: () {
          Navigator.pop(context);
          context.go('/editar-reporte', extra: reporte);
        },
        onEliminar: () {
          Navigator.pop(context);
          _eliminarReporte(reporte);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colores  = Theme.of(context).colorScheme;
    final reportes = ref.watch(reportesProvider).reportes;

    return Scaffold(
      backgroundColor: colores.surface,
      appBar: AppBar(
        title: const Text('Mis reportes'),
        centerTitle: true,
        backgroundColor: colorPrimario,
        foregroundColor: colorBlanco,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/perfil'),
        ),
      ),
      body: reportes.isEmpty ? _mensajeVacio(colores) : _listaReportes(reportes),
    );
  }

  Widget _mensajeVacio(ColorScheme colores) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.pets, size: 64, color: colores.onSurfaceVariant.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Text(
            'No tienes reportes activos',
            style: TextStyle(color: colores.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _listaReportes(List<Reporte> reportes) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: reportes.length,
      itemBuilder: (context, index) {
        final reporte = reportes[index];
        return _TarjetaReporte(
          reporte: reporte,
          onTap: () => _mostrarDetalle(reporte),
          onMarcarEncontrado: () => _marcarEncontrado(reporte),
          onEditar: () => context.go('/editar-reporte', extra: reporte),
          onEliminar: () => _eliminarReporte(reporte),
        );
      },
    );
  }
}

class _TarjetaReporte extends StatelessWidget {
  final Reporte reporte;
  final VoidCallback onTap;
  final VoidCallback onMarcarEncontrado;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _TarjetaReporte({
    required this.reporte,
    required this.onTap,
    required this.onMarcarEncontrado,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final colores      = Theme.of(context).colorScheme;
    final estiloEstado = _estiloEstado();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: colores.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: estiloEstado.color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fotoAnimal(colores),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    reporte.nombre,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: colores.onSurface,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: estiloEstado.color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(estiloEstado.icono, size: 11, color: estiloEstado.color),
                                      const SizedBox(width: 3),
                                      Text(
                                        reporte.encontrado ? 'Encontrada' : 'Perdida',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: estiloEstado.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${reporte.especie} - ${reporte.raza}',
                              style: TextStyle(fontSize: 12, color: colores.onSurfaceVariant),
                            ),
                            const SizedBox(height: 4),
                            _direccionReporte(colores),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.access_time_outlined, size: 12, color: colores.onSurfaceVariant),
                                const SizedBox(width: 3),
                                Text(
                                  _fechaRelativa(reporte.fecha),
                                  style: TextStyle(fontSize: 12, color: colores.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  _botonesReporte(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fotoAnimal(ColorScheme colores) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: reporte.imagenUrl.isNotEmpty
          ? Image.network(
              reporte.imagenUrl,
              width: 64, height: 64, fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _placeholderFoto(colores),
            )
          : _placeholderFoto(colores),
    );
  }

  Widget _placeholderFoto(ColorScheme colores) {
    return Container(
      width: 64, height: 64,
      color: colores.surfaceContainerLow,
      child: Icon(Icons.pets, size: 28, color: colores.onSurfaceVariant.withValues(alpha: 0.4)),
    );
  }

  Widget _direccionReporte(ColorScheme colores) {
    return Row(
      children: [
        Icon(Icons.location_on_outlined, size: 12, color: colores.onSurfaceVariant),
        const SizedBox(width: 2),
        Expanded(
          child: Text(
            reporte.direccion,
            style: TextStyle(color: colores.onSurfaceVariant, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _botonesReporte() {
    if (reporte.encontrado) {
      return SizedBox(
        width: double.infinity,
        child: Listener(
          onPointerDown: (_) {},
          behavior: HitTestBehavior.opaque,
          child: _BotonReporte(
            icono: Icons.delete_outline,
            texto: 'Eliminar',
            color: colorError,
            onTap: onEliminar,
            expandido: true,
          ),
        ),
      );
    }

    return Row(
      children: [
        _BotonReporte(
          icono: Icons.check_circle_outline,
          texto: 'Encontrada',
          color: colorReportar,
          onTap: onMarcarEncontrado,
        ),
        const SizedBox(width: 8),
        _BotonReporte(
          icono: Icons.edit_outlined,
          texto: 'Editar',
          color: colorPrimario,
          onTap: onEditar,
        ),
        const SizedBox(width: 8),
        _BotonReporte(
          icono: Icons.delete_outline,
          texto: 'Eliminar',
          color: colorError,
          onTap: onEliminar,
        ),
      ],
    );
  }

  _EstiloReporte _estiloEstado() {
    if (reporte.encontrado) {
      return const _EstiloReporte(color: colorReportar, icono: Icons.check_circle);
    }
    return const _EstiloReporte(color: colorPerdidas, icono: Icons.error_outline);
  }

  String _fechaRelativa(DateTime fecha) {
    final diff = DateTime.now().difference(fecha);
    if (diff.inDays == 0) return 'Hoy';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} dias';
    if (diff.inDays < 30) return 'Hace ${(diff.inDays / 7).floor()} semanas';
    if (diff.inDays < 365) return 'Hace ${(diff.inDays / 30).floor()} meses';
    return 'Hace ${(diff.inDays / 365).floor()} anios';
  }
}

class _DetalleReporteSheet extends StatelessWidget {
  final Reporte reporte;
  final VoidCallback onMarcarEncontrado;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _DetalleReporteSheet({
    required this.reporte,
    required this.onMarcarEncontrado,
    required this.onEditar,
    required this.onEliminar,
  });

  Color get _colorEstado => reporte.encontrado ? colorReportar : colorPerdidas;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.6,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollController) => SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: colores.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            if (reporte.imagenUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  reporte.imagenUrl,
                  width: double.infinity, height: 180, fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _placeholderImagen(colores),
                ),
              )
            else
              _placeholderImagen(colores),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  reporte.encontrado ? Icons.check_circle : Icons.error_outline,
                  color: _colorEstado, size: 22,
                ),
                const SizedBox(width: 6),
                Text(
                  reporte.encontrado ? 'Encontrada' : 'Perdida',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _colorEstado),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              reporte.nombre,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colores.onSurface),
            ),
            Text(
              '${reporte.especie} - ${reporte.raza}',
              style: TextStyle(fontSize: 14, color: colores.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Text(
              reporte.descripcion,
              style: TextStyle(color: colores.onSurface, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 12),
            _filaInfo(Icons.location_on_outlined, reporte.direccion, colores),
            const SizedBox(height: 6),
            _filaInfo(
              Icons.calendar_today_outlined,
              '${reporte.fecha.day.toString().padLeft(2, '0')}/'
              '${reporte.fecha.month.toString().padLeft(2, '0')}/'
              '${reporte.fecha.year}',
              colores,
            ),
            const SizedBox(height: 6),
            _filaInfo(Icons.phone_outlined, reporte.telefono, colores, color: colorPrimario),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            if (!reporte.encontrado) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onMarcarEncontrado,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorPrimario,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    'Marcar como encontrada',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _BotonAccion(
                icono: Icons.edit_outlined,
                texto: 'Editar reporte',
                color: colorPrimario,
                onTap: onEditar,
              ),
              const SizedBox(height: 10),
            ],
            _BotonAccion(
              icono: Icons.delete_outline,
              texto: 'Eliminar reporte',
              color: colorError,
              onTap: onEliminar,
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImagen(ColorScheme colores) {
    return Container(
      width: double.infinity, height: 180,
      decoration: BoxDecoration(
        color: colores.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.pets, size: 56, color: colores.onSurfaceVariant.withValues(alpha: 0.4)),
    );
  }

  Widget _filaInfo(IconData icono, String texto, ColorScheme colores, {Color? color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, size: 15, color: color ?? colores.onSurfaceVariant),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            texto,
            style: TextStyle(fontSize: 13, color: color ?? colores.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

class _BotonAccion extends StatelessWidget {
  final IconData icono;
  final String texto;
  final Color color;
  final VoidCallback onTap;

  const _BotonAccion({
    required this.icono, required this.texto,
    required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon:  Icon(icono, size: 16, color: color),
        label: Text(texto, style: TextStyle(color: color)),
        style: OutlinedButton.styleFrom(
          side:    BorderSide(color: color),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape:   RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

class _EstiloReporte {
  final Color color;
  final IconData icono;
  const _EstiloReporte({required this.color, required this.icono});
}

class _BotonReporte extends StatelessWidget {
  final IconData icono;
  final String texto;
  final Color color;
  final VoidCallback onTap;
  final bool expandido;

  const _BotonReporte({
    required this.icono, required this.texto,
    required this.color, required this.onTap,
    this.expandido = false,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon:  Icon(icono, size: 14, color: color),
      label: Text(texto, style: TextStyle(fontSize: 12, color: color)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color),
        padding: EdgeInsets.symmetric(
          horizontal: expandido ? 16 : 10,
          vertical:   expandido ? 10 : 6,
        ),
        minimumSize:    expandido ? const Size(double.infinity, 40) : Size.zero,
        tapTargetSize:  MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}