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

NoTransitionPage<void> _paginaSinTransicion(GoRouterState state, Widget child) =>
    NoTransitionPage<void>(key: state.pageKey, child: child);

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
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _paginaSinTransicion(state, const LoginScreen()),
      ),
      GoRoute(
        path: '/registro',
        pageBuilder: (context, state) => _paginaSinTransicion(state, const RegistroScreen()),
      ),
      GoRoute(
        path: '/recuperar-password',
        pageBuilder: (context, state) => _paginaSinTransicion(state, const RecuperarPasswordScreen()),
      ),

      // App Shell (Navigation Bar / Sidebar)
      ShellRoute(
        pageBuilder: (context, state, child) => _paginaSinTransicion(state, AppShell(child: child)),
        routes: [
          // Inicio
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => _paginaSinTransicion(state, const HomeScreen()),
          ),

          // Adopcion
          GoRoute(
            path: '/catalogo',
            pageBuilder: (context, state) => _paginaSinTransicion(state, const CatalogoScreen()),
          ),
          GoRoute(
            path: '/animal/:id',
            pageBuilder: (context, state) {
              final animal = state.extra as Animal;
              return _paginaSinTransicion(state, AnimalDetalleScreen(animal: animal));
            },
          ),

          // Mascotas perdidas
          GoRoute(
            path: '/mapa',
            pageBuilder: (context, state) {
              final reporte = state.extra as Reporte?;
              return _paginaSinTransicion(state, MapaScreen(reporteInicial: reporte));
            },
          ),
          GoRoute(
            path: '/reportar',
            pageBuilder: (context, state) => _paginaSinTransicion(state, const ReportarScreen()),
          ),
          GoRoute(
            path: '/reporte/:id',
            pageBuilder: (context, state) {
              final reporte = state.extra as Reporte;
              return _paginaSinTransicion(state, ReporteDetalleScreen(reporte: reporte));
            },
          ),

          // Perfil y ajustes
          GoRoute(
            path: '/perfil',
            pageBuilder: (context, state) => _paginaSinTransicion(state, const PerfilScreen()),
          ),
          GoRoute(
            path: '/recompensas',
            pageBuilder: (context, state) => _paginaSinTransicion(state, const RecompensasScreen()),
          ),
          GoRoute(
            path: '/notificaciones',
            pageBuilder: (context, state) => _paginaSinTransicion(state, const NotificacionesScreen()),
          ),
          GoRoute(
            path: '/mis-reportes',
            pageBuilder: (context, state) => _paginaSinTransicion(state, const MisReportesScreen()),
          ),
          GoRoute(
            path: '/mis-adopciones',
            pageBuilder: (context, state) => _paginaSinTransicion(state, const MisAdopcionesScreen()),
          ),
          GoRoute(
            path: '/editar-reporte',
            pageBuilder: (context, state) {
              final reporte = state.extra as Reporte;
              return _paginaSinTransicion(state, EditarReporteScreen(reporte: reporte));
            },
          ),
          GoRoute(
            path: '/configuracion',
            pageBuilder: (context, state) => _paginaSinTransicion(state, const ConfiguracionScreen()),
          ),
          GoRoute(
            path: '/mis-recompensas',
            pageBuilder: (context, state) => _paginaSinTransicion(state, const MisPuntosScreen()),
          ),

          // ADMIN ROUTES
          GoRoute(
            path: '/admin/dashboard',
            pageBuilder: (context, state) => _paginaSinTransicion(state, const AdminDashboardScreen()),
          ),
          GoRoute(
            path: '/admin/animales',
            pageBuilder: (context, state) => _paginaSinTransicion(state, const AdminAnimalesScreen()),
          ),
          GoRoute(
            path: '/admin/adopciones',
            pageBuilder: (context, state) => _paginaSinTransicion(state, const AdminAdopcionesScreen()),
          ),
          GoRoute(
            path: '/admin/usuarios',
            pageBuilder: (context, state) => _paginaSinTransicion(state, const AdminUsuariosScreen()),
          ),
          GoRoute(
            path: '/admin/reportes',
            pageBuilder: (context, state) => _paginaSinTransicion(state, const AdminReportesScreen()),
          ),
          GoRoute(
            path: '/admin/bajas',
            pageBuilder: (context, state) => _paginaSinTransicion(state, const AdminHistoricoBajasScreen()),
          ),
          GoRoute(
            path: '/admin/placeholder',
            pageBuilder: (context, state) =>
                _paginaSinTransicion(state, const AdminPlaceholder(title: 'Configuración Admin')),
          ),
        ],
      ),
    ],
  );
});
