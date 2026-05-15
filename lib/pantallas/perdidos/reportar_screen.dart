import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../tema.dart';
import '../../modelos/reporte.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/estadisticas_provider.dart';
import '../../providers/reportes_provider.dart';

// Pantalla para crear un reporte de mascota perdida
class ReportarScreen extends ConsumerStatefulWidget {
  const ReportarScreen({super.key});

  @override
  ConsumerState<ReportarScreen> createState() => _ReportarScreenState();
}

class _ReportarScreenState extends ConsumerState<ReportarScreen> {
  final _nombreController = TextEditingController();
  final _razaController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _ultimoLugarController = TextEditingController();
  final _telefonoController = TextEditingController();
  bool _usandoUbicacion = false;
  File? _imagenSeleccionada;
  String? _especieSeleccionada;
  double? _latitudActual;
  double? _longitudActual;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _nombreController.dispose();
    _razaController.dispose();
    _descripcionController.dispose();
    _ultimoLugarController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  // Validacion basica del formulario
  void _mostrarMensaje(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Valida y guarda el reporte
  void _enviarReporte() {
    final nombre = _nombreController.text.trim();
    final descripcion = _descripcionController.text.trim();
    final telefono = _telefonoController.text.trim();

    if (nombre.isEmpty) {
      _mostrarMensaje('Por favor indica el nombre de la mascota', colorError);
      return;
    }

    if (descripcion.isEmpty) {
      _mostrarMensaje('Por favor describe la mascota', colorError);
      return;
    }

    if (!_usandoUbicacion && _ultimoLugarController.text.trim().isEmpty) {
      _mostrarMensaje('Por favor indica la ubicación', colorError);
      return;
    }

    if (telefono.isEmpty) {
      _mostrarMensaje('Por favor añade un teléfono de contacto', colorError);
      return;
    }

    final nuevoReporte = Reporte(
      id: 'reporte_${DateTime.now().millisecondsSinceEpoch}',
      nombre: nombre,
      raza: _razaController.text.trim(),
      especie: _especieSeleccionada ?? 'Otro',
      descripcion: descripcion,
      telefono: telefono,
      imagenUrl: '',
      latitud: _latitudActual ?? 40.4168,
      longitud: _longitudActual ?? -3.7038,
      direccion: _usandoUbicacion
          ? 'Ubicación GPS actual'
          : _ultimoLugarController.text.trim(),
      fecha: DateTime.now(),
      encontrado: false,
    );

    ref.read(reportesProvider.notifier).agregar(nuevoReporte);

    ref.read(estadisticasProvider.notifier).sumarReporte();

    _mostrarMensaje('Reporte enviado correctamente', colorReportar);
    context.go('/mapa');
  }

  // Seleccion de imagen
  Future<void> _seleccionarFotoDesde(ImageSource source) async {
    final imagen = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 85,
    );

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

  // Abre opciones de camara o galeria
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

  // Borde comun de los campos
  OutlineInputBorder _bordeCampo(Color color, {double ancho = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: color, width: ancho),
    );
  }

  // Campo de texto reutilizado
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
        hintStyle: TextStyle(
          color: colores.onSurfaceVariant.withValues(alpha: 0.6),
          fontSize: 14,
        ),
        filled: true,
        fillColor: colores.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: _bordeCampo(colorBorde),
        enabledBorder: _bordeCampo(colorBorde),
        focusedBorder: _bordeCampo(colorPrimario, ancho: 1.5),
      ),
    );
  }

  // Chip para elegir especie
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
            color: seleccionado
                ? colorPrimario
                : colores.outline.withValues(alpha: 0.25),
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

  // Tarjeta de seccion
  Widget _buildSeccionCard({
    required String titulo,
    required List<Widget> hijos,
  }) {
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
          Text(
            titulo,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colores.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          ...hijos,
        ],
      ),
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
                  _botonEnviar(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Cabecera superior
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
                onPressed: () => context.go('/home'),
              ),
              const SizedBox(width: 4),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reportar mascota perdida',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Ayuda a encontrar a tu amigo. Cuanta más info, mejor.',
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

  // Selector visual de foto
  Widget _selectorFoto() {
    final colores = Theme.of(context).colorScheme;

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
                child: Image.file(
                  _imagenSeleccionada!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              )
            : _selectorFotoVacio(colores),
      ),
    );
  }

  Widget _selectorFotoVacio(ColorScheme colores) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.camera_alt_outlined,
          size: 36,
          color: colores.onSurfaceVariant,
        ),
        const SizedBox(height: 8),
        Text(
          'Subir foto de la mascota',
          style: TextStyle(
            color: colores.onSurfaceVariant,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'JPG, PNG hasta 5MB',
          style: TextStyle(
            color: colores.onSurfaceVariant.withValues(alpha: 0.6),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: _seleccionarFoto,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: colorPrimario.withValues(alpha: 0.6)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          ),
          child: const Text(
            'Seleccionar foto',
            style: TextStyle(color: colorPrimario, fontSize: 13),
          ),
        ),
      ],
    );
  }

  // Nombre de la mascota
  Widget _seccionNombre() {
    return _buildSeccionCard(
      titulo: 'Nombre de la mascota',
      hijos: [
        _buildCampoTexto(
          controller: _nombreController,
          hint: 'Ej: Buddy, Max...',
        ),
      ],
    );
  }

  // Datos fisicos y especie
  Widget _seccionDescripcion() {
    final colores = Theme.of(context).colorScheme;

    return _buildSeccionCard(
      titulo: 'Raza / Descripción física',
      hijos: [
        _buildCampoTexto(
          controller: _razaController,
          hint: 'Ej: Labrador marrón con collar azul...',
        ),
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

  // Ultima ubicacion
  Widget _seccionUbicacion() {
    return _buildSeccionCard(
      titulo: 'Último lugar visto',
      hijos: [
        _buildCampoTexto(
          controller: _ultimoLugarController,
          hint: 'Ej: Calle Mayor nº 15, Madrid',
        ),
        const SizedBox(height: 12),
        _botonUbicacionActual(),
      ],
    );
  }

  // Pide permiso y obtiene la ubicacion
  Future<void> _obtenerUbicacionActual() async {
    final permiso = await Geolocator.requestPermission();

    if (permiso == LocationPermission.denied ||
        permiso == LocationPermission.deniedForever) {
      if (!mounted) return;
      _mostrarMensaje(
        'Necesitamos permiso de ubicación para usar esta función',
        colorError,
      );
      return;
    }

    if (!mounted) return;
    _mostrarMensaje('Obteniendo ubicación...', colorPrimario);

    final posicion = await Geolocator.getCurrentPosition();

    if (!mounted) return;
    setState(() {
      _latitudActual = posicion.latitude;
      _longitudActual = posicion.longitude;
      _usandoUbicacion = true;
      _ultimoLugarController.text = 'Ubicación GPS actual';
    });

    _mostrarMensaje('Ubicación obtenida correctamente', colorReportar);
  }

  // Boton para usar ubicacion actual
  Widget _botonUbicacionActual() {
    final colores = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: _obtenerUbicacionActual,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _usandoUbicacion
              ? colorPrimario.withValues(alpha: 0.08)
              : colores.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _usandoUbicacion
                ? colorPrimario
                : colores.outline.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.my_location,
              color: _usandoUbicacion
                  ? colorPrimario
                  : colores.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: _textoUbicacion(colores)),
            if (_usandoUbicacion)
              const Icon(Icons.check_circle, color: colorPrimario, size: 20),
          ],
        ),
      ),
    );
  }

  // Texto del boton de ubicacion
  Widget _textoUbicacion(ColorScheme colores) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Usar ubicación actual',
          style: TextStyle(
            color: _usandoUbicacion ? colorPrimario : colores.onSurface,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        Text(
          'Se usará tu posición GPS actual',
          style: TextStyle(
            color: colores.onSurfaceVariant.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // Telefono
  Widget _seccionContacto() {
    return _buildSeccionCard(
      titulo: 'Contacto',
      hijos: [
        _buildCampoTexto(
          controller: _telefonoController,
          hint: '+34 612 345 678',
          tipo: TextInputType.phone,
        ),
      ],
    );
  }

  // Boton final
  Widget _botonEnviar() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _enviarReporte,
        icon: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
        label: const Text(
          'Enviar reporte',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorAdoptar,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  // Label de campos
  Widget _labelCampo(String texto, ColorScheme colores) {
    return Text(
      texto,
      style: TextStyle(
        fontSize: 13,
        color: colores.onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
