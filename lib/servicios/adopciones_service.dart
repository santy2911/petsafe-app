import '../modelos/solicitud_adopcion.dart';
import 'api_service.dart';
import 'auth_service.dart';

class AdopcionesService {

  // Obtener todas las solicitudes del usuario actual
  static Future<List<SolicitudAdopcion>> getMisSolicitudes() async {
    // MOCK temporal — eliminar cuando llegue el backend
    await Future.delayed(const Duration(milliseconds: 300));
    return [];

    // Cuando llegue el backend, descomenta esto y borra el mock:
    // final data = await ApiService.get(
    //   '/adopciones/mis-solicitudes',
    //   token: AuthService.token,
    // );
    // return (data as List).map((e) => SolicitudAdopcion.fromJson(e)).toList();
  }

  // Crear una nueva solicitud de adopción
  static Future<SolicitudAdopcion> crearSolicitud({
    required String idAnimal,
    required String comentarios,
  }) async {
    // MOCK temporal — eliminar cuando llegue el backend
    await Future.delayed(const Duration(milliseconds: 300));
    return SolicitudAdopcion(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      idUsuario: AuthService.token ?? '0',
      idAnimal: idAnimal,
      estado: 'pendiente',
      comentarios: comentarios,
      fecha: DateTime.now(),
    );

    // Cuando llegue el backend, descomenta esto y borra el mock:
    // final data = await ApiService.post(
    //   '/adopciones',
    //   {
    //     'idAnimal': idAnimal,
    //     'comentarios': comentarios,
    //   },
    //   token: AuthService.token,
    // );
    // return SolicitudAdopcion.fromJson(data);
  }

  // Cancelar una solicitud pendiente
  static Future<void> cancelarSolicitud(String idSolicitud) async {
    // MOCK temporal — eliminar cuando llegue el backend
    await Future.delayed(const Duration(milliseconds: 300));

    // Cuando llegue el backend, descomenta esto y borra el mock:
    // await ApiService.delete(
    //   '/adopciones/$idSolicitud',
    //   token: AuthService.token,
    // );
  }

  // Comprobar si el usuario ya tiene una solicitud para un animal
  static Future<bool> tieneSolicitud(String idAnimal) async {
    // MOCK temporal
    await Future.delayed(const Duration(milliseconds: 300));
    return false;
  }

  // --- MÉTODOS PARA ADMIN ---

  // Obtener todas las solicitudes del sistema (para el refugio)
  static Future<List<SolicitudAdopcion>> getAllSolicitudes() async {
    // MOCK temporal — usamos el mock que creamos antes
    await Future.delayed(const Duration(milliseconds: 500));
    // Necesitamos importar el mock
    return []; // Se llenará en el provider usando el archivo mock por ahora
  }

  static Future<void> actualizarEstado(String idSolicitud, String nuevoEstado) async {
    // MOCK temporal
    await Future.delayed(const Duration(milliseconds: 500));
  }
}