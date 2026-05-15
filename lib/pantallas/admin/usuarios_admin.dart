import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../tema.dart';
import '../../modelos/usuario.dart';
import '../../providers/usuarios_provider.dart';
import '../../widgets/boton_notificaciones.dart';

class AdminUsuariosScreen extends ConsumerStatefulWidget {
  const AdminUsuariosScreen({super.key});

  @override
  ConsumerState<AdminUsuariosScreen> createState() => _AdminUsuariosScreenState();
}

class _AdminUsuariosScreenState extends ConsumerState<AdminUsuariosScreen> {
  String filtro = '';
  String filtroRol = 'Todos los Roles';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(usuariosProvider);
    
    final usuariosFiltrados = state.usuarios.where((u) {
      final matchesText = u.nombre.toLowerCase().contains(filtro.toLowerCase()) || 
                          u.email.toLowerCase().contains(filtro.toLowerCase());
      final matchesRol = filtroRol == 'Todos los Roles' || u.rol == filtroRol;
      return matchesText && matchesRol;
    }).toList();

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        actions: [
          const BotonNotificaciones(),
          const SizedBox(width: 8),
          IconButton(
            onPressed: state.cargando ? null : () => ref.read(usuariosProvider.notifier).cargarUsuarios(),
            icon: state.cargando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: colorPrimario),
                  )
                : const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) => setState(() => filtro = val),
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre o email...',
                      prefixIcon: const Icon(Icons.search, color: colorTextoSuave),
                      constraints: const BoxConstraints(maxWidth: 500),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                DropdownButton<String>(
                  value: filtroRol,
                  items: const [
                    DropdownMenuItem(value: 'Todos los Roles', child: Text('Todos los Roles')),
                    DropdownMenuItem(value: 'Admin', child: Text('Administradores')),
                    DropdownMenuItem(value: 'User', child: Text('Ciudadanos')),
                  ],
                  onChanged: (val) => setState(() => filtroRol = val!),
                ),
              ],
            ),
          ),
          
          if (state.cargando && state.usuarios.isEmpty)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                decoration: decorationSuperficieLista(),
                clipBehavior: Clip.antiAlias,
                child: ListView.separated(
                  itemCount: usuariosFiltrados.length,
                  separatorBuilder: (context, index) => Divider(height: 1, color: colorTexto.withValues(alpha: 0.08)),
                  itemBuilder: (context, index) {
                    final usuario = usuariosFiltrados[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      leading: CircleAvatar(
                        backgroundImage: usuario.imagenUrl.isNotEmpty ? NetworkImage(usuario.imagenUrl) : null,
                        radius: 24,
                        child: usuario.imagenUrl.isEmpty ? const Icon(Icons.person) : null,
                      ),
                      title: Text(usuario.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(usuario.email),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _RoleBadge(rol: usuario.rol),
                          const SizedBox(width: 16),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert_rounded, color: colorTextoSuave),
                            onSelected: (val) {
                              if (val == 'delete') {
                                _confirmarEliminar(context, usuario);
                              } else if (val == 'toggle_role') {
                                final nuevoRol = usuario.rol == 'Admin' ? 'User' : 'Admin';
                                ref.read(usuariosProvider.notifier).cambiarRol(usuario.id, nuevoRol);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'toggle_role',
                                child: Text(usuario.rol == 'Admin' ? 'Cambiar a Ciudadano' : 'Hacer Administrador'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Eliminar Usuario', style: TextStyle(color: colorError)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _confirmarEliminar(BuildContext context, Usuario usuario) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Usuario'),
        content: Text('¿Estás seguro de que quieres eliminar a ${usuario.nombre}? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              ref.read(usuariosProvider.notifier).eliminarUsuario(usuario.id);
              Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: colorError)),
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String rol;
  const _RoleBadge({required this.rol});

  @override
  Widget build(BuildContext context) {
    final isAdmin = rol == 'Admin';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isAdmin ? colorPrimario.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        rol,
        style: TextStyle(
          color: isAdmin ? colorPrimario : colorTextoSuave,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

