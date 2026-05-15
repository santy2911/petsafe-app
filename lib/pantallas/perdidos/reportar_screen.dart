import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../tema.dart';
import '../../modelos/reporte.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/estadisticas_provider.dart';
import '../../providers/reportes_provider.dart';
import '../../providers/puntos_provider.dart';

class ReportarScreen extends ConsumerStatefulWidget {
  const ReportarScreen({super.key});

  @override
  ConsumerState<ReportarScreen> createState() => _ReportarScreenState();
}

class _ReportarScreenState extends ConsumerState<ReportarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _razaController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _ultimoLugarController = TextEditingController();
  final _telefonoController = TextEditingController();
  
  bool _usandoUbicacion = false;
  bool _cargandoUbicacion = false;
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

  Future<void> _obtenerUbicacionActual() async {
    setState(() => _cargandoUbicacion = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw 'Los servicios de ubicación están desactivados.';

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw 'Permisos de ubicación denegados.';
      }

      if (permission == LocationPermission.deniedForever) throw 'Los permisos de ubicación están denegados permanentemente.';

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _latitudActual = position.latitude;
        _longitudActual = position.longitude;
        _usandoUbicacion = true;
        _cargandoUbicacion = false;
      });
    } catch (e) {
      setState(() => _cargandoUbicacion = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: colorError));
      }
    }
  }

  void _enviarReporte() {
    if (!_formKey.currentState!.validate()) return;
    
    if (_especieSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, selecciona una especie'), backgroundColor: colorError));
      return;
    }

    final nuevoReporte = Reporte(
      id: 'reporte_${DateTime.now().millisecondsSinceEpoch}',
      nombre: _nombreController.text.trim(),
      raza: _razaController.text.trim(),
      especie: _especieSeleccionada!,
      descripcion: _descripcionController.text.trim(),
      telefono: _telefonoController.text.trim(),
      imagenUrl: 'https://images.unsplash.com/photo-1517849845537-4d257902454a?auto=format&fit=crop&q=80&w=400',
      latitud: _latitudActual ?? 40.4168,
      longitud: _longitudActual ?? -3.7038,
      direccion: _usandoUbicacion ? 'Ubicación GPS actual' : _ultimoLugarController.text.trim(),
      fecha: DateTime.now(),
      encontrado: false,
    );

    ref.read(reportesProvider.notifier).agregar(nuevoReporte);
    ref.read(estadisticasProvider.notifier).sumarReporte();
    ref.read(puntosProvider.notifier).sumarPuntos(50, 'Nuevo reporte de mascota'); 
    context.go('/mapa');
  }

  Future<void> _seleccionarFoto() async {
    final imagen = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (imagen != null) setState(() => _imagenSeleccionada = File(imagen.path));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(title: const Text('Reportar Mascota'), leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => context.go('/home'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPhotoPicker(),
              const SizedBox(height: 32),
              _buildSectionTitle('Información Básica'),
              const SizedBox(height: 16),
              _buildTextFormField(_nombreController, 'Nombre de la mascota', (v) => v!.isEmpty ? 'Campo obligatorio' : null),
              const SizedBox(height: 12),
              _buildTextFormField(_razaController, 'Raza (opcional)', null),
              const SizedBox(height: 24),
              _buildSectionTitle('Especie'),
              const SizedBox(height: 16),
              Row(
                children: [
                  _EspecieChip(label: 'Perro', emoji: '🐕', isSelected: _especieSeleccionada == 'Perro', onTap: () => setState(() => _especieSeleccionada = 'Perro')),
                  const SizedBox(width: 12),
                  _EspecieChip(label: 'Gato', emoji: '🐈', isSelected: _especieSeleccionada == 'Gato', onTap: () => setState(() => _especieSeleccionada = 'Gato')),
                  const SizedBox(width: 12),
                  _EspecieChip(label: 'Otro', emoji: '🐾', isSelected: _especieSeleccionada == 'Otro', onTap: () => setState(() => _especieSeleccionada = 'Otro')),
                ],
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Ubicación'),
              const SizedBox(height: 16),
              if (_usandoUbicacion && _latitudActual != null && _longitudActual != null) ...[
                _buildMapPreview(),
              ] else ...[
                _buildTextFormField(_ultimoLugarController, 'Dirección o lugar aproximado', (v) => v!.isEmpty ? 'Por favor indica dónde se vio' : null),
                const SizedBox(height: 12),
                _buildLocationButton(),
              ],
              const SizedBox(height: 24),
              _buildSectionTitle('Contacto y Detalles'),
              const SizedBox(height: 16),
              _buildTextFormField(_telefonoController, 'Teléfono de contacto', (v) => v!.length < 9 ? 'Introduce un teléfono válido' : null, keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              _buildTextFormField(_descripcionController, 'Describe rasgos distintivos...', (v) => v!.length < 10 ? 'Describe un poco más para ayudar a identificarla' : null, maxLines: 4),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _enviarReporte,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorPrimario,
                  foregroundColor: colorBlanco,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Enviar Reporte', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapPreview() {
    return Column(
      children: [
        Container(
          height: 150,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.withValues(alpha: 0.2))),
          clipBehavior: Clip.antiAlias,
          child: FlutterMap(
            options: MapOptions(initialCenter: LatLng(_latitudActual!, _longitudActual!), initialZoom: 15, interactionOptions: const InteractionOptions(flags: InteractiveFlag.none)),
            children: [
              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
              MarkerLayer(markers: [Marker(point: LatLng(_latitudActual!, _longitudActual!), child: const Icon(Icons.location_on, color: Colors.red, size: 30))]),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
            const SizedBox(width: 8),
            const Text('Ubicación GPS fijada', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
            const Spacer(),
            TextButton(onPressed: () => setState(() => _usandoUbicacion = false), child: const Text('Cambiar')),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationButton() {
    return OutlinedButton.icon(
      onPressed: _cargandoUbicacion ? null : _obtenerUbicacionActual,
      icon: _cargandoUbicacion ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.my_location_rounded, size: 18),
      label: Text(_cargandoUbicacion ? 'Obteniendo...' : 'Usar ubicación actual'),
      style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
    );
  }

  Widget _buildPhotoPicker() {
    return GestureDetector(
      onTap: _seleccionarFoto,
      child: Container(
        width: double.infinity, height: 200,
        decoration: BoxDecoration(color: colorAcentoLight, borderRadius: BorderRadius.circular(24), border: Border.all(color: colorAcentoRosa.withValues(alpha: 0.1))),
        child: _imagenSeleccionada != null
            ? ClipRRect(borderRadius: BorderRadius.circular(24), child: Image.file(_imagenSeleccionada!, fit: BoxFit.cover))
            : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: colorAcentoRosa.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.add_a_photo_rounded, color: colorAcentoRosa, size: 32)),
                const SizedBox(height: 16),
                const Text('Añadir Foto', style: TextStyle(fontWeight: FontWeight.bold, color: colorTexto)),
                const Text('Haz click para seleccionar', style: TextStyle(color: colorTextoSuave, fontSize: 12)),
              ]),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorTexto));
  }

  Widget _buildTextFormField(TextEditingController controller, String hint, String? Function(String?)? validator, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(hintText: hint),
    );
  }
}

class _EspecieChip extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;
  const _EspecieChip({required this.label, required this.emoji, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(color: isSelected ? colorPrimario : colorBlanco, borderRadius: BorderRadius.circular(16), border: Border.all(color: isSelected ? colorPrimario : const Color(0xFFF1F5F9))),
          child: Column(children: [Text(emoji, style: const TextStyle(fontSize: 24)), const SizedBox(height: 8), Text(label, style: TextStyle(color: isSelected ? colorBlanco : colorTexto, fontWeight: FontWeight.bold, fontSize: 13))]),
        ),
      ),
    );
  }
}
