import '../modelos/usuario.dart';
import 'api_service.dart';
import 'auth_service.dart';

class UsuarioService {

  static Future<Usuario> getPerfil() async {
    // Cuando llegue el backend, descomenta esto y borra el mock:
    // final data = await ApiService.get('/usuarios/perfil', token: AuthService.token);
    // return Usuario.fromJson(data);

    // MOCK temporal
    await Future.delayed(const Duration(milliseconds: 300));
    return Usuario(
      id: '1',
      nombre: 'Usuario Demo',
      email: 'usuario@demo.com',
      telefono: '600000000',
      imagenUrl: '',
    );
  }

  static Future<void> actualizarPerfil(Usuario usuario) async {
    // Cuando llegue el backend, descomenta esto y borra el mock:
    // await ApiService.put(
    //   '/usuarios/perfil',
    //   usuario.toJson(),
    //   token: AuthService.token,
    // );

    // MOCK temporal
    await Future.delayed(const Duration(milliseconds: 300));
  }

  static Future<int> getPuntos() async {
    // Cuando llegue el backend, descomenta esto y borra el mock:
    // final data = await ApiService.get('/usuarios/puntos', token: AuthService.token);
    // return data['puntos'];

    // MOCK temporal
    await Future.delayed(const Duration(milliseconds: 300));
    return 350;
  }

  // Estadísticas del usuario (adopciones realizadas y reportes publicados)
  static Future<Map<String, int>> getEstadisticas() async {
    // Cuando llegue el backend, descomenta esto y borra el mock:
    // final data = await ApiService.get(
    //   '/usuarios/estadisticas',
    //   token: AuthService.token,
    // );
    // return {
    //   'adopciones': data['adopciones'] as int,
    //   'reportes': data['reportes'] as int,
    // };

    // MOCK temporal
    await Future.delayed(const Duration(milliseconds: 300));
    return {'adopciones': 0, 'reportes': 0};
  }
}