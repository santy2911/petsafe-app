import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../modelos/usuario.dart';
import 'api_service.dart';

// Necesitas añadir esta dependencia en pubspec.yaml:
// flutter_secure_storage: ^9.0.0

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _keyToken = 'auth_token';

  // Login — devuelve el usuario y guarda el token de forma segura
  static Future<Usuario> login(String email, String password) async {
    // Cuando llegue el backend, descomenta esto y borra el mock:
    // final data = await ApiService.post('/auth/login', {
    //   'email': email,
    //   'password': password,
    // });
    // await _guardarToken(data['token']);
    // return Usuario.fromJson(data['usuario']);

    // MOCK temporal
    await Future.delayed(const Duration(seconds: 1));
    await _guardarToken('token-mock-123');
    return Usuario(
      id: '1',
      nombre: 'Usuario Demo',
      email: email,
      telefono: '600000000',
      imagenUrl: '',
    );
  }

  // Registro
  static Future<void> registro(String nombre, String email, String password) async {
    // Cuando llegue el backend, descomenta esto y borra el mock:
    // await ApiService.post('/auth/registro', {
    //   'nombre': nombre,
    //   'email': email,
    //   'password': password,
    // });

    // MOCK temporal
    await Future.delayed(const Duration(seconds: 1));
  }

  // Recuperar contraseña
  static Future<void> recuperarPassword(String email) async {
    // Cuando llegue el backend, descomenta esto y borra el mock:
    // await ApiService.post('/auth/recuperar-password', {'email': email});

    // MOCK temporal
    await Future.delayed(const Duration(seconds: 1));
  }

  // Logout — borra el token del almacenamiento seguro
  static Future<void> logout() async {
    await _storage.delete(key: _keyToken);
    _tokenEnMemoria = null;
  }

  // Recupera el token guardado al arrancar la app
  // Llamar en main.dart antes de decidir si ir a login o home
  static Future<bool> iniciarSesionGuardada() async {
    final token = await _storage.read(key: _keyToken);
    if (token != null) {
      _tokenEnMemoria = token;
      return true;
    }
    return false;
  }

  static Future<void> _guardarToken(String token) async {
    _tokenEnMemoria = token;
    await _storage.write(key: _keyToken, value: token);
  }

  // Token en memoria para acceso rápido sin leer storage cada vez
  static String? _tokenEnMemoria;
  static String? get token => _tokenEnMemoria;
}