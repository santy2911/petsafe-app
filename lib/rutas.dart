import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'pantallas/auth/login_screen.dart';
import 'pantallas/auth/registro_screen.dart';
import 'pantallas/auth/recuperar_password_screen.dart';
import 'pantallas/home_screen.dart';
import 'pantallas/adopcion/catalogo_screen.dart';
import 'pantallas/adopcion/detalle_animal_screen.dart';
import 'pantallas/perdidos/mapa_screen.dart';
import 'pantallas/perdidos/reportar_screen.dart';
import 'pantallas/perdidos/reporte_detalle_screen.dart';
import 'pantallas/perfil/recompensas_screen.dart';
import 'pantallas/notificaciones/notificaciones_screen.dart';
import 'pantallas/perfil/perfil_screen.dart';
import 'pantallas/perfil/editar_perfil_screen.dart';
import 'pantallas/perfil/mis_reportes_screen.dart';
import 'pantallas/perfil/mis_adopciones_screen.dart';
import 'pantallas/perfil/editar_reporte_screen.dart';
import 'pantallas/perfil/configuracion_screen.dart';
import 'pantallas/perfil/mis_puntos_screen.dart';
import 'pantallas/admin/dashboard_admin.dart';
import 'pantallas/admin/animales_admin.dart';
import 'pantallas/admin/adopciones_admin.dart';
import 'pantallas/admin/usuarios_admin.dart';
import 'pantallas/admin/reportes_admin.dart';
import 'pantallas/admin/bajas_admin.dart';
import 'pantallas/admin/placeholder.dart';
import 'widgets/app_shell.dart';
import 'modelos/animal.dart';
import 'modelos/reporte.dart';
import 'providers/auth_provider.dart';

// Provider del Router para poder escuchar cambios en el Auth
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    
    // Lógica de Redirección (Auth Guard)
    redirect: (context, state) {
      final logueado = authState.usuarioActual != null;
      final enAuth = state.matchedLocation == '/login' || 
                     state.matchedLocation == '/registro' || 
                     state.matchedLocation == '/recuperar-password';

      // 1. Si no está logueado y no está en una pantalla de auth -> al Login
      if (!logueado) {
        return enAuth ? null : '/login';
      }

      // 2. Si está logueado pero está en pantallas de auth -> al Home (según rol)
      if (enAuth) {
        return authState.usuarioActual?.rol == 'Admin' ? '/admin/dashboard' : '/home';
      }

      // 3. Si intenta entrar en admin sin ser admin -> al Home ciudadano
      if (state.matchedLocation.startsWith('/admin') && authState.usuarioActual?.rol != 'Admin') {
        return '/home';
      }

      return null;
    },

    routes: [
      // Login y registro (Fuera del Shell)
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/registro', builder: (context, state) => const RegistroScreen()),
      GoRoute(path: '/recuperar-password', builder: (context, state) => const RecuperarPasswordScreen()),

      // App Shell (Navigation Bar / Sidebar)
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          // Inicio
          GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),

          // Adopcion
          GoRoute(path: '/catalogo', builder: (context, state) => const CatalogoScreen()),
          GoRoute(
            path: '/animal/:id',
            builder: (context, state) {
              final animal = state.extra as Animal;
              return AnimalDetalleScreen(animal: animal);
            },
          ),

          // Mascotas perdidas
          GoRoute(
            path: '/mapa',
            builder: (context, state) {
              final reporte = state.extra as Reporte?;
              return MapaScreen(reporteInicial: reporte);
            },
          ),
          GoRoute(path: '/reportar', builder: (context, state) => const ReportarScreen()),
          GoRoute(
            path: '/reporte/:id',
            builder: (context, state) {
              final reporte = state.extra as Reporte;
              return ReporteDetalleScreen(reporte: reporte);
            },
          ),

          // Perfil y ajustes
          GoRoute(path: '/perfil', builder: (context, state) => const PerfilScreen()),
          GoRoute(path: '/recompensas', builder: (context, state) => const RecompensasScreen()),
          GoRoute(path: '/notificaciones', builder: (context, state) => const NotificacionesScreen()),
          GoRoute(path: '/mis-reportes', builder: (context, state) => const MisReportesScreen()),
          GoRoute(path: '/mis-adopciones', builder: (context, state) => const MisAdopcionesScreen()),
          GoRoute(
            path: '/editar-reporte',
            builder: (context, state) {
              final reporte = state.extra as Reporte;
              return EditarReporteScreen(reporte: reporte);
            },
          ),
          GoRoute(path: '/configuracion', builder: (context, state) => const ConfiguracionScreen()),
          GoRoute(path: '/mis-recompensas', builder: (context, state) => const MisPuntosScreen()),

          // ADMIN ROUTES
          GoRoute(path: '/admin/dashboard', builder: (context, state) => const AdminDashboardScreen()),
          GoRoute(path: '/admin/animales', builder: (context, state) => const AdminAnimalesScreen()),
          GoRoute(path: '/admin/adopciones', builder: (context, state) => const AdminAdopcionesScreen()),
          GoRoute(path: '/admin/usuarios', builder: (context, state) => const AdminUsuariosScreen()),
          GoRoute(path: '/admin/reportes', builder: (context, state) => const AdminReportesScreen()),
          GoRoute(path: '/admin/bajas', builder: (context, state) => const AdminHistoricoBajasScreen()),
          GoRoute(path: '/admin/placeholder', builder: (context, state) => const AdminPlaceholder(title: 'Configuración Admin')),
        ],
      ),
    ],
  );
});
