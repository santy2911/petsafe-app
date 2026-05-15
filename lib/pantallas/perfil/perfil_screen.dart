import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../tema.dart';
import '../../widgets/navbar.dart';
import '../../providers/estadisticas_provider.dart';
import '../../providers/perfil_provider.dart';
import '../../providers/puntos_provider.dart';

// Pantalla de perfil del usuario
class PerfilScreen extends ConsumerStatefulWidget {
  const PerfilScreen({super.key});

  @override
  ConsumerState<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends ConsumerState<PerfilScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _seleccionarFoto() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _opcionFoto(
              context: context,
              icono: Icons.camera_alt,
              texto: 'Tomar foto',
              fuente: ImageSource.camera,
            ),
            _opcionFoto(
              context: context,
              icono: Icons.photo_library,
              texto: 'Elegir de la galería',
              fuente: ImageSource.gallery,
            ),
          ],
        ),
      ),
    );
  }

  Widget _opcionFoto({
    required BuildContext context,
    required IconData icono,
    required String texto,
    required ImageSource fuente,
  }) {
    return ListTile(
      leading: Icon(icono),
      title: Text(texto),
      onTap: () async {
        Navigator.pop(context);
        final imagen = await _picker.pickImage(source: fuente);
        if (imagen != null) {
          final file = File(imagen.path);
          // Guarda la foto en el provider para que persista
          ref.read(perfilProvider.notifier).actualizarFoto(file);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final stats = ref.watch(estadisticasProvider);

    return Scaffold(
      backgroundColor: colores.surface,
      bottomNavigationBar: const NavbarPrincipal(indiceActual: 2),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cabeceraPerfil(),
              _contadores(stats),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _seccionActividad(colores),
                    const SizedBox(height: 28),
                    _seccionConfiguracion(colores),
                    const SizedBox(height: 28),
                    _botonCerrarSesion(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cabeceraPerfil() {
    return Container(
      width: double.infinity,
      color: colorPrimario,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tituloPerfil(),
          const SizedBox(height: 16),
          _datosUsuario(),
          const SizedBox(height: 20),
          const _TarjetaPuntos(),
        ],
      ),
    );
  }

  Widget _tituloPerfil() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Mi Perfil',
          style: TextStyle(
            color: colorBlanco,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          onTap: () => context.go('/editar-perfil'),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: colorBlanco.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.edit_outlined,
              color: colorBlanco,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _datosUsuario() {
    // Lee nombre y foto del provider
    final perfil = ref.watch(perfilProvider);

    return Row(
      children: [
        GestureDetector(
          onTap: _seleccionarFoto,
          child: Stack(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: colorBlanco.withValues(alpha: 0.3),
                backgroundImage: perfil.foto != null
                    ? FileImage(perfil.foto!)
                    : null,
                child: perfil.foto == null
                    ? const Icon(Icons.person, color: colorBlanco, size: 38)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorAdoptar,
                    shape: BoxShape.circle,
                    border: Border.all(color: colorPrimario, width: 1.5),
                  ),
                  child: const Icon(Icons.camera_alt, color: colorBlanco, size: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              perfil.nombre,
              style: const TextStyle(
                color: colorBlanco,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, color: colorBlanco, size: 14),
                const SizedBox(width: 2),
                Text(
                  'España',
                  style: TextStyle(
                    color: colorBlanco.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _contadores(EstadisticasState stats) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ContadorEstadistica(
            emoji: '❤️',
            cantidad: stats.adopciones,
            etiqueta: 'Adopciones',
          ),
          const _Divisor(),
          _ContadorEstadistica(
            emoji: '📢',
            cantidad: stats.reportes,
            etiqueta: 'Reportes',
          ),
        ],
      ),
    );
  }

  Widget _seccionActividad(ColorScheme colores) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TituloSeccion(texto: 'Mi actividad', colores: colores),
        const SizedBox(height: 12),
        _TarjetaOpcion(
          icono: Icons.favorite_outline,
          iconoColor: colorError,
          texto: 'Mis adopciones',
          badge: 1,
          onTap: () => context.go('/mis-adopciones'),
        ),
        const SizedBox(height: 10),
        _TarjetaOpcion(
          icono: Icons.warning_amber_outlined,
          iconoColor: const Color(0xFFF59E0B),
          texto: 'Mis reportes',
          badge: 1,
          onTap: () => context.go('/mis-reportes'),
        ),
        const SizedBox(height: 10),
        _TarjetaOpcion(
          icono: Icons.star_outline,
          iconoColor: const Color(0xFFF59E0B),
          texto: 'Mis puntos',
          badge: 3,
          onTap: () => context.go('/mis-recompensas'),
        ),
      ],
    );
  }

  Widget _seccionConfiguracion(ColorScheme colores) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TituloSeccion(texto: 'Configuración', colores: colores),
        const SizedBox(height: 10),
        _TarjetaOpcion(
          icono: Icons.settings_outlined,
          iconoColor: colorPrimario,
          texto: 'Ajustes de cuenta',
          onTap: () => context.go('/configuracion'),
        ),
      ],
    );
  }

  Widget _botonCerrarSesion() {
    return GestureDetector(
      onTap: _mostrarDialogoCerrarSesion,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: colorError.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colorError.withValues(alpha: 0.2)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: colorError, size: 20),
            SizedBox(width: 8),
            Text(
              'Cerrar sesión',
              style: TextStyle(
                color: colorError,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoCerrarSesion() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('👋', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            const Text(
              '¿Cerrar sesión?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorTexto,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '¿Seguro que quieres salir de tu cuenta?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: colorTextoSuave),
            ),
            const SizedBox(height: 24),
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
                      side: const BorderSide(color: Color(0xFFDDDDDD)),
                    ),
                    child: const Text('Cancelar', style: TextStyle(color: colorTexto)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.go('/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorError,
                      foregroundColor: colorBlanco,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cerrar sesión'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Tarjeta de puntos en la cabecera — lee del provider automáticamente
class _TarjetaPuntos extends ConsumerWidget {
  const _TarjetaPuntos();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final puntos = ref.watch(puntosProvider).puntos;
    final nivel = ref.watch(nivelProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorBlanco.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '⭐ $puntos puntos',
                style: const TextStyle(
                  color: colorBlanco,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                nivel.siguiente != null
                    ? '→ ${nivel.siguiente!.puntosMinimos} para ${nivel.siguiente!.nombre.replaceFirst('Nivel ', '')}'
                    : '¡Nivel máximo!',
                style: TextStyle(
                  color: colorBlanco.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: calcularProgreso(puntos, nivel),
              minHeight: 8,
              backgroundColor: colorBlanco.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(colorAcento),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${nivel.emoji} ${nivel.nombre}',
            style: TextStyle(
              color: colorBlanco.withValues(alpha: 0.85),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _TituloSeccion extends StatelessWidget {
  final String texto;
  final ColorScheme colores;

  const _TituloSeccion({required this.texto, required this.colores});

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: colores.onSurface,
      ),
    );
  }
}

class _ContadorEstadistica extends StatelessWidget {
  final String emoji;
  final int cantidad;
  final String etiqueta;

  const _ContadorEstadistica({
    required this.emoji,
    required this.cantidad,
    required this.etiqueta,
  });

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 4),
        Text(
          '$cantidad',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colores.onSurface,
          ),
        ),
        Text(
          etiqueta,
          style: TextStyle(fontSize: 12, color: colores.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _Divisor extends StatelessWidget {
  const _Divisor();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}

class _TarjetaOpcion extends StatelessWidget {
  final IconData icono;
  final Color iconoColor;
  final String texto;
  final int? badge;
  final VoidCallback onTap;

  const _TarjetaOpcion({
    required this.icono,
    required this.iconoColor,
    required this.texto,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colores.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icono, color: iconoColor, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                texto,
                style: TextStyle(
                  fontSize: 15,
                  color: colores.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorPrimario,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$badge',
                  style: const TextStyle(
                    color: colorBlanco,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Icon(Icons.chevron_right, color: colores.onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }
}