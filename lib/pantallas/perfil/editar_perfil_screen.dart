import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../tema.dart';
import '../../providers/perfil_provider.dart';

// Pantalla para cambiar nombre y foto de perfil
class EditarPerfilScreen extends ConsumerStatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  ConsumerState<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends ConsumerState<EditarPerfilScreen> {
  late TextEditingController _nombreController;
  final _imagePicker = ImagePicker();
  File? _imagenSeleccionada;

  @override
  void initState() {
    super.initState();
    // Cargar los datos actuales del usuario
    final nombreActual = ref.read(perfilProvider).nombre;
    _nombreController = TextEditingController(
      text: nombreActual == 'Usuario' ? '' : nombreActual,
    );

    final fotoActual = ref.read(perfilProvider).foto;
    if (fotoActual != null) _imagenSeleccionada = fotoActual;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  // Abre el menu para elegir camara o galeria
  Future<void> _seleccionarImagen() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Foto de perfil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _opcionImagen(ctx: ctx, icono: Icons.camera_alt, texto: 'Tomar foto', fuente: ImageSource.camera),
            _opcionImagen(ctx: ctx, icono: Icons.photo_library, texto: 'Elegir de galería', fuente: ImageSource.gallery),
          ],
        ),
      ),
    );
  }

  // Cada fila del menu de imagen
  Widget _opcionImagen({
    required BuildContext ctx,
    required IconData icono,
    required String texto,
    required ImageSource fuente,
  }) {
    return ListTile(
      leading: Icon(icono, color: colorPrimario),
      title: Text(texto),
      onTap: () async {
        Navigator.pop(ctx);
        await _abrirPicker(fuente);
      },
    );
  }

  // Llama al picker nativo del telefono
  Future<void> _abrirPicker(ImageSource fuente) async {
    final picked = await _imagePicker.pickImage(source: fuente, imageQuality: 80, maxWidth: 600);
    if (picked != null) setState(() => _imagenSeleccionada = File(picked.path));
  }

  // Valida y guarda los cambios en Riverpod
  void _guardarCambios() {
    final nombre = _nombreController.text.trim();

    if (nombre.isEmpty) {
      _mostrarMensaje('Por favor introduce tu nombre', colorError);
      return;
    }

    ref.read(perfilProvider.notifier).actualizarNombre(nombre);
    if (_imagenSeleccionada != null) {
      ref.read(perfilProvider.notifier).actualizarFoto(_imagenSeleccionada!);
    }

    _mostrarMensaje('Perfil actualizado correctamente', colorAdoptar);
    context.go('/perfil');
  }

  // Snackbar de exito o error
  void _mostrarMensaje(String texto, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: color),
    );
  }

  // Borde para los inputs
  OutlineInputBorder _bordeCampo({BorderSide borderSide = BorderSide.none}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: borderSide,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colores.surface,
      appBar: AppBar(
        title: const Text('Editar perfil'),
        centerTitle: true,
        backgroundColor: colorPrimario,
        foregroundColor: colorBlanco,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/perfil'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _avatarPerfil(),
            const SizedBox(height: 8),
            const Text('Toca para cambiar la foto', style: TextStyle(fontSize: 12, color: colorTextoSuave)),
            const SizedBox(height: 32),
            _campoNombre(colores),
            const SizedBox(height: 12),
            _avisoAjustes(),
            const SizedBox(height: 32),
            _botonGuardar(),
          ],
        ),
      ),
    );
  }

  // Avatar circular con boton de camara encima
  Widget _avatarPerfil() {
    return GestureDetector(
      onTap: _seleccionarImagen,
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: colorPrimario,
              shape: BoxShape.circle,
              image: _imagenSeleccionada != null
                  ? DecorationImage(image: FileImage(_imagenSeleccionada!), fit: BoxFit.cover)
                  : null,
            ),
            child: _imagenSeleccionada == null
                ? const Icon(Icons.person, color: colorBlanco, size: 50)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: colorAdoptar, shape: BoxShape.circle),
              child: const Icon(Icons.camera_alt, color: colorBlanco, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  // Input para el nombre
  Widget _campoNombre(ColorScheme colores) {
    return TextField(
      controller: _nombreController,
      decoration: InputDecoration(
        hintText: 'Nombre de usuario',
        prefixIcon: const Icon(Icons.person_outlined, color: colorPrimario),
        filled: true,
        fillColor: colores.surfaceContainerHighest,
        border: _bordeCampo(),
        enabledBorder: _bordeCampo(),
        focusedBorder: _bordeCampo(borderSide: const BorderSide(color: colorPrimario, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  // Cuadro informativo
  Widget _avisoAjustes() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorPrimario.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: colorPrimario, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 12, color: colorPrimario),
                children: [
                  const TextSpan(text: 'Para cambiar tu email o teléfono ve a '),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () => context.go('/configuracion'),
                      child: const Text(
                        'Ajustes de cuenta',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorPrimario,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Boton para guardar
  Widget _botonGuardar() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _guardarCambios,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorPrimario,
          foregroundColor: colorBlanco,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: const Text('Guardar cambios', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}