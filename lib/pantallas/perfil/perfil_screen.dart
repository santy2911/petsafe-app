import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../tema.dart';
import '../../providers/estadisticas_provider.dart';
import '../../providers/perfil_provider.dart';
import '../../providers/puntos_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/adopciones_provider.dart';
import '../../providers/reportes_provider.dart';
import '../../providers/animales_provider.dart';
import '../../widgets/boton_notificaciones.dart';

class PerfilScreen extends ConsumerStatefulWidget {
  const PerfilScreen({super.key});

  @override
  ConsumerState<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends ConsumerState<PerfilScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _seleccionarFoto() async {
    final imagen = await _picker.pickImage(source: ImageSource.gallery);
    if (imagen != null) {
      ref.read(perfilProvider.notifier).actualizarFoto(File(imagen.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final perfil = ref.watch(perfilProvider);
    final authState = ref.watch(authProvider);
    final user = authState.usuarioActual;

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          const BotonNotificaciones(),
          IconButton(
            onPressed: () => _mostrarDialogoEdicion(context, user),
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Editar Perfil',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildHeader(perfil, user),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => context.go('/recompensas'),
                        child: const _TarjetaPuntosPremium(),
                      ),
                      const SizedBox(height: 32),
                      _buildSectionTitle('Mis Solicitudes de Adopción'),
                      const SizedBox(height: 16),
                      const _ListaMisSolicitudes(),
                      const SizedBox(height: 32),
                      _buildSectionTitle('Mis Reportes de Mascota'),
                      const SizedBox(height: 16),
                      const _ListaMisReportes(),
                      const SizedBox(height: 32),
                      _buildSectionTitle('Configuración'),
                      const SizedBox(height: 16),
                      _MenuOption(icon: Icons.settings_rounded, color: colorPrimario, label: 'Ajustes de Cuenta', onTap: () => context.go('/configuracion')),
                      _MenuOption(icon: Icons.help_rounded, color: Colors.blue, label: 'Ayuda y Soporte', onTap: () {}),
                      const SizedBox(height: 48),
                      _buildLogoutButton(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(PerfilState perfil, user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: const BoxDecoration(
        color: colorBlanco,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _seleccionarFoto,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: colorFondo,
                  backgroundImage: perfil.foto != null ? FileImage(perfil.foto!) : null,
                  child: perfil.foto == null ? const Icon(Icons.person_rounded, size: 50, color: colorTextoSuave) : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: colorPrimario, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(user?.nombre ?? perfil.nombre, style: const TextStyle(color: colorTexto, fontSize: 24, fontWeight: FontWeight.bold)),
          Text(user?.rol == 'Admin' ? 'Administrador' : 'Usuario PetSafe', style: const TextStyle(color: colorTextoSuave, fontSize: 14)),
        ],
      ),
    );
  }

  void _mostrarDialogoEdicion(BuildContext context, user) {
    final nombreCtrl = TextEditingController(text: user?.nombre);
    final telefonoCtrl = TextEditingController(text: user?.telefono);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
            const SizedBox(height: 16),
            TextField(controller: telefonoCtrl, decoration: const InputDecoration(labelText: 'Teléfono'), keyboardType: TextInputType.phone),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).actualizarPerfil(nombreCtrl.text, telefonoCtrl.text);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorTexto));
  }

  Widget _buildLogoutButton() {
    return ElevatedButton.icon(
      onPressed: () => ref.read(authProvider.notifier).logout(),
      icon: const Icon(Icons.logout_rounded),
      label: const Text('Cerrar Sesión'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        foregroundColor: Colors.red,
        elevation: 0,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

class _TarjetaPuntosPremium extends ConsumerWidget {
  const _TarjetaPuntosPremium();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final puntosState = ref.watch(puntosProvider);
    final puntos = puntosState.puntos;
    final nivel = ref.watch(nivelProvider);
    final progreso = calcularProgreso(puntos, nivel);
    final historial = puntosState.historial.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: const Color(0xFF4F46E5).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tus Puntos', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  Row(
                    children: [
                      const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 28),
                      const SizedBox(width: 8),
                      Text('$puntos XP', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(16)),
                child: Text(nivel.emoji, style: const TextStyle(fontSize: 24)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(value: progreso, minHeight: 10, backgroundColor: Colors.white12, valueColor: const AlwaysStoppedAnimation<Color>(Colors.white)),
          ),
          const SizedBox(height: 12),
          Text(nivel.nombre, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          
          const SizedBox(height: 20),
          const Divider(color: Colors.white24),
          const SizedBox(height: 12),
          const Text('Actividad reciente', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (historial.isEmpty)
            const Text('No hay movimientos recientes', style: TextStyle(color: Colors.white54, fontSize: 12))
          else
            ...historial.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(m.accion, style: const TextStyle(color: Colors.white, fontSize: 13)),
                  Text('+${m.puntos} XP', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            )),
        ],
      ),
    );
  }
}

class _ListaMisSolicitudes extends ConsumerWidget {
  const _ListaMisSolicitudes();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final solicitudes = ref.watch(adopcionesProvider).solicitudes;

    if (solicitudes.isEmpty) {
      return _EmptyState(icon: Icons.favorite_border_rounded, text: 'Aún no has solicitado ninguna adopción');
    }

    return Column(
      children: solicitudes.map((s) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () {
            // Buscamos el animal en el provider para tener el objeto completo
            final animal = ref.read(animalesProvider).animales.firstWhere((a) => a.id == s.idAnimal);
            context.push('/animal/${animal.id}', extra: animal);
          },
          borderRadius: BorderRadius.circular(12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(s.urlImagenAnimal, width: 60, height: 60, fit: BoxFit.cover),
            ),
            title: Text(s.nombreAnimal, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Solicitado: ${s.fechaSolicitud.toString().split(' ')[0]}'),
            trailing: _StatusChip(estado: s.estado),
          ),
        ),
      )).toList(),
    );
  }
}

class _ListaMisReportes extends ConsumerWidget {
  const _ListaMisReportes();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportes = ref.watch(reportesProvider).reportes;

    if (reportes.isEmpty) {
      return _EmptyState(icon: Icons.warning_amber_rounded, text: 'No tienes reportes activos');
    }

    return Column(
      children: reportes.map((r) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () => context.push('/reporte/${r.id}', extra: r),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(r.imagenUrl, width: 60, height: 60, fit: BoxFit.cover),
                ),
                title: Text(r.descripcion, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(r.fecha.toString().split(' ')[0]),
                trailing: _StatusChip(estado: r.encontrado ? 'Encontrado' : 'Perdido'),
              ),
              if (!r.encontrado)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () => _confirmarEncontrado(context, ref, r.id),
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Marcar como encontrado'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorPrimarioLight,
                        foregroundColor: colorPrimario,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      )).toList(),
    );
  }

  void _confirmarEncontrado(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Has encontrado a tu mascota?'),
        content: const Text('El reporte se marcará como solucionado y recibirás 100 puntos extra.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              ref.read(reportesProvider.notifier).marcarEncontrado(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('¡Excelente noticia! Has ganado 100 puntos.'), backgroundColor: colorReportar),
              );
            },
            child: const Text('¡Sí, encontrado!'),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String estado;
  const _StatusChip({required this.estado});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (estado.toLowerCase()) {
      case 'aceptada':
      case 'encontrado':
        color = colorPrimario; break;
      case 'rechazada':
      case 'perdido':
        color = colorAcento; break;
      case 'pendiente':
        color = Colors.orange; break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(estado, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;
  const _EmptyState({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(icon, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(text, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _MenuOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  const _MenuOption({required this.icon, required this.color, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color)),
          title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          trailing: const Icon(Icons.chevron_right_rounded, color: colorTextoSuave),
        ),
      ),
    );
  }
}