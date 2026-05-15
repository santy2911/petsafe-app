import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../modelos/usuario.dart';
import '../servicios/usuario_service.dart';

class EstadoPerfil {
  final Usuario? usuario;
  final File? foto;
  final bool cargando;
  final String? error;

  const EstadoPerfil({
    this.usuario,
    this.foto,
    this.cargando = false,
    this.error,
  });

  // Nombre con fallback para que las pantallas no rompan si usuario es null
  String get nombre => usuario?.nombre ?? 'Usuario';

  EstadoPerfil copyWith({
    Usuario? usuario,
    File? foto,
    bool? cargando,
    String? error,
  }) {
    return EstadoPerfil(
      usuario: usuario ?? this.usuario,
      foto: foto ?? this.foto,
      cargando: cargando ?? this.cargando,
      error: error,
    );
  }
}

class PerfilNotifier extends StateNotifier<EstadoPerfil> {
  PerfilNotifier() : super(const EstadoPerfil()) {
    cargarPerfil();
  }

  Future<void> cargarPerfil() async {
    state = state.copyWith(cargando: true);
    try {
      final usuario = await UsuarioService.getPerfil();
      state = state.copyWith(usuario: usuario, cargando: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), cargando: false);
    }
  }

  Future<void> actualizarPerfil(Usuario usuarioActualizado) async {
    state = state.copyWith(cargando: true);
    try {
      await UsuarioService.actualizarPerfil(usuarioActualizado);
      state = state.copyWith(usuario: usuarioActualizado, cargando: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), cargando: false);
    }
  }

  // Solo actualiza la foto localmente (la subida de imagen al servidor
  // se añadirá cuando el backend tenga el endpoint de upload)
  void actualizarFoto(File foto) {
    state = state.copyWith(foto: foto);
  }

  // Mantiene compatibilidad con las pantallas que usan actualizarNombre
  Future<void> actualizarNombre(String nombre) async {
    if (state.usuario == null) return;
    final actualizado = Usuario(
      id: state.usuario!.id,
      nombre: nombre,
      email: state.usuario!.email,
      telefono: state.usuario!.telefono,
      imagenUrl: state.usuario!.imagenUrl,
    );
    await actualizarPerfil(actualizado);
  }
}

final perfilProvider = StateNotifierProvider<PerfilNotifier, EstadoPerfil>(
  (ref) => PerfilNotifier(),
);