import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../modelos/usuario.dart';
import '../datos/usuarios_mock.dart';

class UsuariosState {
  final List<Usuario> usuarios;
  final bool cargando;
  final String? error;

  const UsuariosState({
    this.usuarios = const [],
    this.cargando = false,
    this.error,
  });

  UsuariosState copyWith({
    List<Usuario>? usuarios,
    bool? cargando,
    String? error,
  }) {
    return UsuariosState(
      usuarios: usuarios ?? this.usuarios,
      cargando: cargando ?? this.cargando,
      error: error,
    );
  }
}

class UsuariosNotifier extends StateNotifier<UsuariosState> {
  UsuariosNotifier() : super(const UsuariosState()) {
    cargarUsuarios();
  }

  Future<void> cargarUsuarios() async {
    state = state.copyWith(cargando: true);
    try {
      // Mock: Simular carga del backend
      await Future.delayed(const Duration(milliseconds: 500));
      state = state.copyWith(usuarios: usuariosMock, cargando: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), cargando: false);
    }
  }

  Future<void> cambiarRol(String id, String nuevoRol) async {
    state = state.copyWith(cargando: true);
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final nuevas = state.usuarios.map((u) {
        if (u.id == id) {
          return Usuario(
            id: u.id,
            nombre: u.nombre,
            email: u.email,
            telefono: u.telefono,
            imagenUrl: u.imagenUrl,
            rol: nuevoRol,
          );
        }
        return u;
      }).toList();
      state = state.copyWith(usuarios: nuevas, cargando: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), cargando: false);
    }
  }

  Future<void> eliminarUsuario(String id) async {
    state = state.copyWith(cargando: true);
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final nuevas = state.usuarios.where((u) => u.id != id).toList();
      state = state.copyWith(usuarios: nuevas, cargando: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), cargando: false);
    }
  }
}

final usuariosProvider = StateNotifierProvider<UsuariosNotifier, UsuariosState>((ref) {
  return UsuariosNotifier();
});
