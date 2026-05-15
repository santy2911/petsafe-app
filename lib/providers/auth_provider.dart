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
  AuthNotifier() : super(AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(cargando: true, error: null);
    try {
      final usuario = await AuthService.login(email, password);
      state = state.copyWith(usuarioActual: usuario, cargando: false);
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

  void logout() {
    AuthService.logout();
    state = AuthState();
  }
}

// Provider global
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});