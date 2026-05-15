import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../modelos/usuario.dart';
import '../servicios/auth_service.dart';

// Estado del auth
class AuthState {
  final Usuario? usuarioActual;
  final bool cargando;
  final String? error;

  AuthState({
    this.usuarioActual,
    this.cargando = false,
    this.error,
  });

  AuthState copyWith({
    Usuario? usuarioActual,
    bool? cargando,
    String? error,
  }) {
    return AuthState(
      usuarioActual: usuarioActual ?? this.usuarioActual,
      cargando: cargando ?? this.cargando,
      error: error ?? this.error,
    );
  }
}

// Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    checkAuth();
  }

  Future<void> checkAuth() async {
    final hasToken = await AuthService.iniciarSesionGuardada();
    if (hasToken) {
      // Si hay token, intentamos recuperar el perfil del usuario
      try {
        // Podríamos llamar a un endpoint /me aquí, por ahora usamos el mock
        final usuario = Usuario(
          id: '1',
          nombre: 'Usuario Recuperado',
          email: 'demo@petsafe.es',
          telefono: '600000000',
          imagenUrl: '',
          rol: 'User', // Por defecto, luego el backend dirá el rol real
        );
        state = state.copyWith(usuarioActual: usuario);
      } catch (e) {
        logout();
      }
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(cargando: true, error: null);
    try {
      final usuario = await AuthService.login(email, password);
      // Actualizamos el usuario con el rol basado en el email para el demo
      final usuarioConRol = Usuario(
        id: usuario.id,
        nombre: usuario.nombre,
        email: usuario.email,
        telefono: usuario.telefono,
        imagenUrl: usuario.imagenUrl,
        rol: email == 'admin@petsafe.es' ? 'Admin' : 'User',
      );
      state = state.copyWith(usuarioActual: usuarioConRol, cargando: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), cargando: false);
    }
  }

  Future<void> registro(String nombre, String email, String password) async {
    state = state.copyWith(cargando: true, error: null);
    try {
      await AuthService.registro(nombre, email, password);
      state = state.copyWith(cargando: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), cargando: false);
    }
  }

  Future<void> recuperarPassword(String email) async {
    state = state.copyWith(cargando: true, error: null);
    try {
      await AuthService.recuperarPassword(email);
      state = state.copyWith(cargando: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), cargando: false);
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    state = AuthState();
  }

  Future<void> actualizarPerfil(String nombre, String telefono) async {
    if (state.usuarioActual == null) return;
    
    state = state.copyWith(cargando: true, error: null);
    try {
      final id = state.usuarioActual!.id;
      final rol = state.usuarioActual!.rol;
      final email = state.usuarioActual!.email;
      
      final actualizado = await AuthService.actualizarPerfil(id, nombre, telefono);
      
      // Mantenemos el rol y el email (que el mock de arriba resetea)
      final completo = Usuario(
        id: actualizado.id,
        nombre: actualizado.nombre,
        email: email,
        telefono: actualizado.telefono,
        imagenUrl: actualizado.imagenUrl,
        rol: rol,
      );
      
      state = state.copyWith(usuarioActual: completo, cargando: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), cargando: false);
    }
  }
}

// Provider global
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});