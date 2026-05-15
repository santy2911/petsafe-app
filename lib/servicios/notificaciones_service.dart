import '../modelos/notificacion.dart';
import 'api_service.dart';
import 'auth_service.dart';

class NotificacionesService {

  // Obtener todas las notificaciones del usuario
  static Future<List<Notificacion>> getNotificaciones() async {
    // MOCK temporal — eliminar cuando llegue el backend
    await Future.delayed(const Duration(milliseconds: 300));
    return [];

    // Cuando llegue el backend, descomenta esto y borra el mock:
    // final data = await ApiService.get(
    //   '/notificaciones',
    //   token: AuthService.token,
    // );
    // return (data as List).map((e) => Notificacion.fromJson(e)).toList();
  }

  // Marcar una notificación como leída
  static Future<void> marcarLeida(String idNotificacion) async {
    // MOCK temporal — eliminar cuando llegue el backend
    await Future.delayed(const Duration(milliseconds: 200));

    // Cuando llegue el backend, descomenta esto y borra el mock:
    // await ApiService.put(
    //   '/notificaciones/$idNotificacion/leida',
    //   {},
    //   token: AuthService.token,
    // );
  }

  // Marcar todas como leídas
  static Future<void> marcarTodasLeidas() async {
    // MOCK temporal — eliminar cuando llegue el backend
    await Future.delayed(const Duration(milliseconds: 200));

    // Cuando llegue el backend, descomenta esto y borra el mock:
    // await ApiService.put(
    //   '/notificaciones/leer-todas',
    //   {},
    //   token: AuthService.token,
    // );
  }

  // Registrar el token push del dispositivo en el backend
  // Llamar a este método justo después del login
  static Future<void> registrarTokenPush(String tokenPush) async {
    // MOCK temporal — eliminar cuando llegue el backend
    await Future.delayed(const Duration(milliseconds: 200));

    // Cuando llegue el backend, descomenta esto y borra el mock:
    // await ApiService.post(
    //   '/notificaciones/token-push',
    //   {'tokenPush': tokenPush},
    //   token: AuthService.token,
    // );
  }
}