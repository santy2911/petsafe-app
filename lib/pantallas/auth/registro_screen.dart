import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../tema.dart';
import '../../providers/auth_provider.dart';

class RegistroScreen extends ConsumerStatefulWidget {
  const RegistroScreen({super.key});

  @override
  ConsumerState<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends ConsumerState<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmarPasswordController = TextEditingController();
  bool _ocultarPassword = true;
  bool _ocultarConfirmar = true;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmarPasswordController.dispose();
    super.dispose();
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: colorError),
    );
  }

  Future<void> _registrarse() async {
    if (!_formKey.currentState!.validate()) return;

    final nombre = _nombreController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      await ref.read(authProvider.notifier).registro(nombre, email, password);
      
      if (mounted) {
        final state = ref.read(authProvider);
        if (state.error != null) {
          _mostrarError(state.error!);
        } else {
          await ref.read(authProvider.notifier).login(email, password);
          if (mounted) context.go('/home');
        }
      }
    } catch (e) {
      _mostrarError('Error en el registro: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: colorBlanco,
      body: Column(
        children: [
          ClipPath(
            clipper: _CabeceraCurvaClipper(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 60, left: 24, right: 24),
              color: colorPrimario,
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.go('/login'),
                    ),
                    const SizedBox(height: 20),
                    const Text('Crear cuenta', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: colorBlanco)),
                    const Text('Únete a la comunidad PetSafe', style: TextStyle(fontSize: 14, color: colorBlanco)),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldTitle('Nombre completo'),
                    TextFormField(
                      controller: _nombreController,
                      validator: (v) => v!.isEmpty ? 'Por favor introduce tu nombre' : null,
                      decoration: const InputDecoration(hintText: 'Tu nombre', prefixIcon: Icon(Icons.person_outlined)),
                    ),
                    const SizedBox(height: 20),
                    _buildFieldTitle('Email'),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => !v!.contains('@') ? 'Email no válido' : null,
                      decoration: const InputDecoration(hintText: 'correo@ejemplo.com', prefixIcon: Icon(Icons.email_outlined)),
                    ),
                    const SizedBox(height: 20),
                    _buildFieldTitle('Contraseña'),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _ocultarPassword,
                      validator: (v) => v!.length < 6 ? 'Mínimo 6 caracteres' : null,
                      decoration: InputDecoration(
                        hintText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(_ocultarPassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _ocultarPassword = !_ocultarPassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildFieldTitle('Confirmar contraseña'),
                    TextFormField(
                      controller: _confirmarPasswordController,
                      obscureText: _ocultarConfirmar,
                      validator: (v) => v != _passwordController.text ? 'Las contraseñas no coinciden' : null,
                      decoration: InputDecoration(
                        hintText: 'Repite la contraseña',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(_ocultarConfirmar ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _ocultarConfirmar = !_ocultarConfirmar),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: authState.cargando ? null : _registrarse,
                      child: authState.cargando ? const CircularProgressIndicator(color: Colors.white) : const Text('Crear cuenta'),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text('¿Ya tienes cuenta? Inicia sesión', style: TextStyle(color: colorTextoSuave)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colorTextoSuave)),
    );
  }
}

class _CabeceraCurvaClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(size.width / 2, size.height - 40, size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(_CabeceraCurvaClipper oldClipper) => false;
}
