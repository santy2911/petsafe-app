import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../tema.dart';
import '../providers/auth_provider.dart';

final sidebarColapsadaProvider = StateProvider<bool>((ref) => false);

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool esEscritorio = MediaQuery.of(context).size.width > 900;
    final String rutaActual = GoRouterState.of(context).uri.path;
    final authState = ref.watch(authProvider);
    final esAdmin = authState.usuarioActual?.rol == 'Admin';
    final enRutaAdmin = rutaActual.startsWith('/admin');

    if (esEscritorio) {
      return Scaffold(
        body: Row(
          children: [
            _Sidebar(rutaActual: rutaActual, esAdmin: esAdmin, enRutaAdmin: enRutaAdmin),
            const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFF1F5F9)),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      // Solo mostramos BottomNav en la vista de ciudadano
      bottomNavigationBar: !enRutaAdmin ? _BottomNav(rutaActual: rutaActual) : null,
    );
  }
}

class _Sidebar extends ConsumerWidget {
  final String rutaActual;
  final bool esAdmin;
  final bool enRutaAdmin;

  const _Sidebar({
    required this.rutaActual,
    required this.esAdmin,
    required this.enRutaAdmin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colapsada = ref.watch(sidebarColapsadaProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: colapsada ? 80 : 280,
      color: colorBlanco,
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Botón Toggle
          Align(
            alignment: colapsada ? Alignment.center : Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: colapsada ? 0 : 16),
              child: IconButton(
                onPressed: () => ref.read(sidebarColapsadaProvider.notifier).state = !colapsada,
                icon: Icon(
                  colapsada ? Icons.menu_open_rounded : Icons.menu_rounded,
                  color: colorTextoSuave,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Logo / Nombre
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: colapsada ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: colorPrimario, borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.pets_rounded, color: Colors.white, size: 24),
                ),
                if (!colapsada) ...[
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'PetSafe',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorTexto, letterSpacing: -0.5),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildDivider(colapsada, destacado: true),
          const SizedBox(height: 8),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (esAdmin && enRutaAdmin) ...[
                    _SidebarItem(label: 'Dashboard', icono: Icons.dashboard_rounded, ruta: '/admin/dashboard', activo: rutaActual == '/admin/dashboard', colapsada: colapsada),
                    _buildDivider(colapsada),
                    _SidebarItem(label: 'Animales', icono: Icons.pets_rounded, ruta: '/admin/animales', activo: rutaActual == '/admin/animales', colapsada: colapsada),
                    _buildDivider(colapsada),
                    _SidebarItem(label: 'Adopciones', icono: Icons.favorite_rounded, ruta: '/admin/adopciones', activo: rutaActual == '/admin/adopciones', colapsada: colapsada),
                    _buildDivider(colapsada),
                    _SidebarItem(label: 'Usuarios', icono: Icons.people_rounded, ruta: '/admin/usuarios', activo: rutaActual == '/admin/usuarios', colapsada: colapsada),
                    _buildDivider(colapsada),
                    _SidebarItem(label: 'Reportes', icono: Icons.warning_rounded, ruta: '/admin/reportes', activo: rutaActual == '/admin/reportes', colapsada: colapsada),
                    _buildDivider(colapsada),
                    _SidebarItem(label: 'Histórico', icono: Icons.history_rounded, ruta: '/admin/bajas', activo: rutaActual == '/admin/bajas', colapsada: colapsada),
                    _buildDivider(colapsada),
                    const SizedBox(height: 16),
                    _SidebarItem(label: 'Vista Usuario', icono: Icons.swap_horiz_rounded, ruta: '/home', activo: rutaActual == '/home', colapsada: colapsada),
                  ] else ...[
                    _SidebarItem(label: 'Inicio', icono: Icons.home_rounded, ruta: '/home', activo: rutaActual == '/home', colapsada: colapsada),
                    _buildDivider(colapsada),
                    _SidebarItem(label: 'Adoptar', icono: Icons.favorite_rounded, ruta: '/catalogo', activo: rutaActual == '/catalogo', colapsada: colapsada),
                    _buildDivider(colapsada),
                    _SidebarItem(label: 'Mapa', icono: Icons.map_rounded, ruta: '/mapa', activo: rutaActual == '/mapa', colapsada: colapsada),
                    _buildDivider(colapsada),
                    _SidebarItem(label: 'Perfil', icono: Icons.person_rounded, ruta: '/perfil', activo: rutaActual == '/perfil', colapsada: colapsada),
                    if (esAdmin) ...[
                      _buildDivider(colapsada),
                      const SizedBox(height: 16),
                      _SidebarItem(label: 'Panel Admin', icono: Icons.admin_panel_settings_rounded, ruta: '/admin/dashboard', activo: rutaActual == '/admin/dashboard', colapsada: colapsada),
                    ],
                  ],
                ],
              ),
            ),
          ),

          _LogoutButton(colapsada: colapsada),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDivider(bool colapsada, {bool destacado = false}) {
    return Divider(
      height: destacado ? 32 : 1,
      thickness: destacado ? 1.5 : 1,
      color: colorTexto.withValues(alpha: destacado ? 0.18 : 0.08),
      indent: colapsada ? 12 : 24,
      endIndent: colapsada ? 12 : 24,
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final String label;
  final IconData icono;
  final String ruta;
  final bool activo;
  final bool colapsada;

  const _SidebarItem({
    required this.label,
    required this.icono,
    required this.ruta,
    required this.activo,
    required this.colapsada,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Tooltip(
        message: widget.colapsada ? widget.label : '',
        child: InkWell(
          onTap: () => context.go(widget.ruta),
          onHover: (hover) => setState(() => _isHovered = hover),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 48,
            decoration: BoxDecoration(
              color: widget.activo ? colorPrimarioLight : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: widget.colapsada ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: widget.colapsada ? 0 : 16),
                  child: Icon(
                    widget.icono, 
                    color: widget.activo ? colorPrimario : colorTexto, 
                    size: 22,
                  ),
                ),
                if (!widget.colapsada)
                  Expanded(
                    child: Text(
                      widget.label, 
                      style: TextStyle(
                        color: widget.activo ? colorPrimario : colorTexto, 
                        fontWeight: widget.activo ? FontWeight.bold : FontWeight.w500, 
                        fontSize: 15
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatefulWidget {
  final bool colapsada;
  const _LogoutButton({required this.colapsada});

  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Tooltip(
            message: widget.colapsada ? 'Cerrar Sesión' : '',
            child: InkWell(
              onTap: () => ref.read(authProvider.notifier).logout(),
              onHover: (hover) => setState(() => _isHovered = hover),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: widget.colapsada ? MainAxisAlignment.center : MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: widget.colapsada ? 0 : 16),
                      child: const Icon(
                        Icons.logout_rounded, 
                        color: colorAcentoRosa, 
                        size: 22,
                      ),
                    ),
                    if (!widget.colapsada)
                      const Expanded(
                        child: Text(
                          'Cerrar Sesión', 
                          style: TextStyle(color: colorAcentoRosa, fontWeight: FontWeight.bold, fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}

class _BottomNav extends StatelessWidget {
  final String rutaActual;
  const _BottomNav({required this.rutaActual});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              indicatorColor: colorPrimarioLight,
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorPrimario);
                }
                return const TextStyle(fontSize: 12, color: colorTextoSuave);
              }),
            ),
            child: NavigationBar(
              height: 64,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedIndex: _getSelectedIndex(rutaActual),
              onDestinationSelected: (idx) => _onItemTapped(context, idx),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home_rounded, color: colorTextoSuave), selectedIcon: Icon(Icons.home_rounded, color: colorPrimario), label: 'Home'),
                NavigationDestination(icon: Icon(Icons.favorite_rounded, color: colorTextoSuave), selectedIcon: Icon(Icons.favorite_rounded, color: colorPrimario), label: 'Adoptar'),
                NavigationDestination(icon: Icon(Icons.map_rounded, color: colorTextoSuave), selectedIcon: Icon(Icons.map_rounded, color: colorPrimario), label: 'Mapa'),
                NavigationDestination(icon: Icon(Icons.person_rounded, color: colorTextoSuave), selectedIcon: Icon(Icons.person_rounded, color: colorPrimario), label: 'Perfil'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _getSelectedIndex(String ruta) {
    if (ruta.startsWith('/home')) return 0;
    if (ruta.startsWith('/catalogo')) return 1;
    if (ruta.startsWith('/mapa')) return 2;
    if (ruta.startsWith('/perfil')) return 3;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/home'); break;
      case 1: context.go('/catalogo'); break;
      case 2: context.go('/mapa'); break;
      case 3: context.go('/perfil'); break;
    }
  }
}


