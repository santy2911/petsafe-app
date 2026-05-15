import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../tema.dart';
import '../../modelos/reporte.dart';

// Pantalla para editar un reporte de mascota perdida
class EditarReporteScreen extends StatefulWidget {
  final Reporte reporte;
  const EditarReporteScreen({super.key, required this.reporte});

  @override
  State<EditarReporteScreen> createState() => _EditarReporteScreenState();
}

class _EditarReporteScreenState extends State<EditarReporteScreen> {
  // Controladores de los campos del formulario
  late TextEditingController _nombreController;
  late TextEditingController _razaController;
  late TextEditingController _descripcionController;
  late TextEditingController _direccionController;
  late TextEditingController _telefonoController;
  late String? _especieSeleccionada;
  File? _imagenSeleccionada;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.reporte.nombre);
    _razaController = TextEditingController(text: widget.reporte.raza);
    _descripcionController = TextEditingController(text: widget.reporte.descripcion);
    _direccionController = TextEditingController(text: widget.reporte.direccion);
    _telefonoController = TextEditingController(text: widget.reporte.telefono);
    _especieSeleccionada = widget.reporte.especie.isNotEmpty ? widget.reporte.especie : null;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _razaController.dispose();
    _descripcionController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  // Valida los campos y actualiza el objeto reporte
  void _guardar() {
    final nombre = _nombreController.text.trim();
    final descripcion = _descripcionController.text.trim();
    final direccion = _direccionController.text.trim();
    final telefono = _telefonoController.text.trim();

    if (nombre.isEmpty) {
      _mostrarMensaje('El nombre no puede estar vacío', colorError);
      return;
    }
    if (descripcion.isEmpty) {
      _mostrarMensaje('La descripción no puede estar vacía', colorError);
      return;
    }
    if (direccion.isEmpty) {
      _mostrarMensaje('La dirección no puede estar vacía', colorError);
      return;
    }
    if (telefono.isEmpty) {
      _mostrarMensaje('El teléfono no puede estar vacío', colorError);
      return;
    }

    // Guarda los cambios en el objeto
    widget.reporte.nombre = nombre;
    widget.reporte.raza = _razaController.text.trim();
    widget.reporte.especie = _especieSeleccionada ?? 'Otro';
    widget.reporte.descripcion = descripcion;
    widget.reporte.direccion = direccion;
    widget.reporte.telefono = telefono;

    _mostrarMensaje('Reporte actualizado correctamente', colorReportar);
    context.go('/mis-reportes');
  }

  // Snackbar generico para errores y confirmaciones
  void _mostrarMensaje(String texto, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: color),
    );
  }

  // Abre camara o galeria y comprueba que no supere 5MB
  Future<void> _seleccionarFotoDesde(ImageSource source) async {
    final imagen = await _imagePicker.pickImage(source: source, maxWidth: 1600, imageQuality: 85);
    if (imagen == null) return;

    final archivo = File(imagen.path);
    final pesoEnBytes = await archivo.length();
    const maximoBytes = 5 * 1024 * 1024;

    if (!mounted) return;

    if (pesoEnBytes > maximoBytes) {
      _mostrarMensaje('La imagen no puede superar los 5MB', colorError);
      return;
    }

    setState(() => _imagenSeleccionada = archivo);
  }

  // Menu inferior para elegir origen de la foto
  Future<void> _seleccionarFoto() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.pop(context);
                _seleccionarFotoDesde(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Elegir de la galeria'),
              onTap: () {
                Navigator.pop(context);
                _seleccionarFotoDesde(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Borde redondeado para los inputs
  OutlineInputBorder _bordeCampo(Color color, {double ancho = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: color, width: ancho),
    );
  }

  // Input de texto reutilizable
  Widget _buildCampoTexto({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType tipo = TextInputType.text,
  }) {
    final colores = Theme.of(context).colorScheme;
    final colorBorde = colores.outline.withValues(alpha: 0.25);

    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: tipo,
      style: TextStyle(color: colores.onSurface, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: colores.onSurfaceVariant.withValues(alpha: 0.6), fontSize: 14),
        filled: true,
        fillColor: colores.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: _bordeCampo(colorBorde),
        enabledBorder: _bordeCampo(colorBorde),
        focusedBorder: _bordeCampo(colorPrimario, ancho: 1.5),
      ),
    );
  }

  // Chip para seleccionar la especie
  Widget _buildEspecieChip(String label, String emoji) {
    final colores = Theme.of(context).colorScheme;
    final seleccionado = _especieSeleccionada == label;

    return GestureDetector(
      onTap: () => setState(() => _especieSeleccionada = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: seleccionado ? colorPrimario : colores.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: seleccionado ? colorPrimario : colores.outline.withValues(alpha: 0.25),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: seleccionado ? Colors.white : colores.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tarjeta contenedora con titulo y campos dentro
  Widget _buildSeccionCard({required String titulo, required List<Widget> hijos}) {
    final colores = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colores.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colores.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colores.onSurface)),
          const SizedBox(height: 14),
          ...hijos,
        ],
      ),
    );
  }

  // Etiqueta pequeña encima de un campo
  Widget _labelCampo(String texto, ColorScheme colores) {
    return Text(
      texto,
      style: TextStyle(fontSize: 13, color: colores.onSurfaceVariant, fontWeight: FontWeight.w500),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colores.surface,
      body: Column(
        children: [
          _cabecera(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _selectorFoto(),
                  const SizedBox(height: 20),
                  _seccionNombre(),
                  const SizedBox(height: 16),
                  _seccionDescripcion(),
                  const SizedBox(height: 16),
                  _seccionUbicacion(),
                  const SizedBox(height: 16),
                  _seccionContacto(),
                  const SizedBox(height: 28),
                  _botonGuardar(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Barra superior con degradado
  Widget _cabecera() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorPrimario, Color(0xFF2E7D52)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 16, 20),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.go('/mis-reportes'),
              ),
              const SizedBox(width: 4),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Editar reporte',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Actualiza los datos de tu mascota perdida.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Zona de foto con preview si ya hay imagen
  Widget _selectorFoto() {
    final colores = Theme.of(context).colorScheme;
    final tieneImagenRed = widget.reporte.imagenUrl.isNotEmpty;

    return GestureDetector(
      onTap: _seleccionarFoto,
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          color: colores.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colores.outline.withValues(alpha: 0.2)),
        ),
        child: _imagenSeleccionada != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(_imagenSeleccionada!, fit: BoxFit.cover, width: double.infinity),
              )
            : tieneImagenRed
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      widget.reporte.imagenUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, _, _) => _selectorFotoVacio(colores),
                    ),
                  )
                : _selectorFotoVacio(colores),
      ),
    );
  }

  // Placeholder cuando no hay foto o falla la carga
  Widget _selectorFotoVacio(ColorScheme colores) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.camera_alt_outlined, size: 36, color: colores.onSurfaceVariant),
        const SizedBox(height: 8),
        Text(
          'Cambiar foto de la mascota',
          style: TextStyle(color: colores.onSurfaceVariant, fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          'JPG, PNG hasta 5MB',
          style: TextStyle(color: colores.onSurfaceVariant.withValues(alpha: 0.6), fontSize: 11),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: _seleccionarFoto,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: colorPrimario.withValues(alpha: 0.6)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          ),
          child: const Text('Seleccionar foto', style: TextStyle(color: colorPrimario, fontSize: 13)),
        ),
      ],
    );
  }

  // Secciones del formulario
  Widget _seccionNombre() {
    return _buildSeccionCard(
      titulo: 'Nombre de la mascota',
      hijos: [_buildCampoTexto(controller: _nombreController, hint: 'Ej: Buddy, Max...')],
    );
  }

  Widget _seccionDescripcion() {
    final colores = Theme.of(context).colorScheme;

    return _buildSeccionCard(
      titulo: 'Raza / Descripción física',
      hijos: [
        _buildCampoTexto(controller: _razaController, hint: 'Ej: Labrador marrón con collar azul...'),
        const SizedBox(height: 14),
        _labelCampo('Especie', colores),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildEspecieChip('Perro', '🐕'),
            const SizedBox(width: 8),
            _buildEspecieChip('Gato', '🐈'),
            const SizedBox(width: 8),
            _buildEspecieChip('Otro', '🐾'),
          ],
        ),
        const SizedBox(height: 14),
        _labelCampo('Descripción detallada *', colores),
        const SizedBox(height: 8),
        _buildCampoTexto(
          controller: _descripcionController,
          hint: 'Describe rasgos físicos, comportamiento, color, microchip...',
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _seccionUbicacion() {
    return _buildSeccionCard(
      titulo: 'Último lugar visto',
      hijos: [_buildCampoTexto(controller: _direccionController, hint: 'Ej: Calle Mayor nº 15, Madrid')],
    );
  }

  Widget _seccionContacto() {
    return _buildSeccionCard(
      titulo: 'Contacto',
      hijos: [_buildCampoTexto(controller: _telefonoController, hint: '+34 612 345 678', tipo: TextInputType.phone)],
    );
  }

  // Boton de guardar al final del scroll
  Widget _botonGuardar() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _guardar,
        icon: const Icon(Icons.save_rounded, size: 18, color: Colors.white),
        label: const Text(
          'Guardar cambios',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorAdoptar,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 2,
        ),
      ),
    );
  }
}