import 'package:go_router/go_router.dart';
import 'pantallas/auth/login_screen.dart';
import 'pantallas/auth/registro_screen.dart';
import 'pantallas/auth/recuperar_password_screen.dart';
import 'pantallas/home_screen.dart';
import 'pantallas/adopcion/catalogo_screen.dart';
import 'pantallas/adopcion/detalle_animal_screen.dart';
import 'pantallas/perdidos/mapa_screen.dart';
import 'pantallas/perdidos/reportar_screen.dart';
import 'pantallas/perfil/perfil_screen.dart';
import 'pantallas/perfil/editar_perfil_screen.dart';
import 'pantallas/perfil/mis_reportes_screen.dart';
import 'pantallas/perfil/mis_adopciones_screen.dart';
import 'pantallas/perfil/editar_reporte_screen.dart';
import 'pantallas/perfil/configuracion_screen.dart';
import 'pantallas/notificaciones_screen.dart';
import 'modelos/animal.dart';
import 'modelos/reporte.dart';
import 'pantallas/perfil/mis_puntos_screen.dart';

// Rutas principales de la app
final rutasApp = GoRouter(
  initialLocation: '/login',
  routes: [
    // Login y registro
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/registro',
      builder: (context, state) => const RegistroScreen(),
    ),
    GoRoute(
      path: '/recuperar-password',
      builder: (context, state) => const RecuperarPasswordScreen(),
    ),

    // Inicio
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),

    // Adopcion
    GoRoute(
      path: '/catalogo',
      builder: (context, state) => const CatalogoScreen(),
    ),
    GoRoute(
      path: '/animal/:id',
      // Animal recibido desde otra pantalla
      builder: (context, state) {
        final animal = state.extra as Animal;
        return DetalleAnimalScreen(animal: animal);
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
    GoRoute(
      path: '/reportar',
      builder: (context, state) => const ReportarScreen(),
    ),

    // Perfil y ajustes
    GoRoute(path: '/perfil', builder: (context, state) => const PerfilScreen()),
    GoRoute(
      path: '/editar-perfil',
      builder: (context, state) => const EditarPerfilScreen(),
    ),
    GoRoute(
      path: '/mis-reportes',
      builder: (context, state) => const MisReportesScreen(),
    ),
    GoRoute(
      path: '/mis-adopciones',
      builder: (context, state) => const MisAdopcionesScreen(),
    ),
    GoRoute(
      path: '/editar-reporte',
      // Reporte recibido desde otra pantalla
      builder: (context, state) {
        final reporte = state.extra as Reporte;
        return EditarReporteScreen(reporte: reporte);
      },
    ),
    GoRoute(
      path: '/configuracion',
      builder: (context, state) => const ConfiguracionScreen(),
    ),
    GoRoute(
      path: '/mis-recompensas',
      builder: (context, state) => const MisPuntosScreen(),
    ),

    // Notificaciones
    GoRoute(
      path: '/notificaciones',
      builder: (context, state) => const NotificacionesScreen(),
    ),
  ],
);
