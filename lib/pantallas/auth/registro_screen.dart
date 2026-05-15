import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../tema.dart';

// Pantalla de registro
class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmarPasswordController = TextEditingController();
  bool _ocultarPassword = true;
  bool _ocultarConfirmar = true;
  bool _pulsado = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmarPasswordController.dispose();
    super.dispose();
  }

  // Muestra errores del formulario
  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: colorError),
    );
  }

  // Comprueba los datos del registro
  void _registrarse() {
    final nombre = _nombreController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmar = _confirmarPasswordController.text.trim();

    if (nombre.isEmpty || email.isEmpty || password.isEmpty || confirmar.isEmpty) {
      _mostrarError('Por favor rellena todos los campos');
      return;
    }
    if (!email.contains('@')) {
      _mostrarError('Introduce un email válido');
      return;
    }
    if (password.length < 6) {
      _mostrarError('La contraseña debe tener al menos 6 caracteres');
      return;
    }
    if (password != confirmar) {
      _mostrarError('Las contraseñas no coinciden');
      return;
    }

    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBlanco,
      body: Column(
        children: [
          // Cabecera con curva y huellas decorativas
          ClipPath(
            clipper: _CabeceraCurvaClipper(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 60, left: 24, right: 24),
              color: colorPrimario,
              child: SafeArea(
                bottom: false,
                child: Stack(
                  children: [
                    // Huellas decorativas
                    Positioned(top: -10, right: 20, child: _HuellaDecorativa(size: 80, opacidad: 0.12)),
                    Positioned(top: 10, left: 30, child: _HuellaDecorativa(size: 60, opacidad: 0.15)),
                    Positioned(bottom: 0, right: 50, child: _HuellaDecorativa(size: 45, opacidad: 0.10)),
                    // Contenido
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Botón volver
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: colorBlanco.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.arrow_back, color: colorBlanco, size: 20),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Crear cuenta',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: colorBlanco),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Únete a la comunidad PetSafe',
                          style: TextStyle(fontSize: 14, color: colorBlanco),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Formulario de registro
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre
                  const Text(
                    'Nombre completo',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colorTextoSuave),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      hintText: 'Tu nombre',
                      prefixIcon: Icon(Icons.person_outlined, color: colorTextoSuave),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Email
                  const Text(
                    'Email',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colorTextoSuave),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'correo@ejemplo.com',
                      prefixIcon: Icon(Icons.email_outlined, color: colorTextoSuave),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Contraseña
                  const Text(
                    'Contraseña',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colorTextoSuave),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _passwordController,
                    obscureText: _ocultarPassword,
                    decoration: InputDecoration(
                      hintText: 'Mínimo 6 caracteres',
                      prefixIcon: const Icon(Icons.lock_outlined, color: colorTextoSuave),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _ocultarPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: colorTextoSuave,
                        ),
                        onPressed: () => setState(() => _ocultarPassword = !_ocultarPassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Confirmar contraseña
                  const Text(
                    'Confirmar contraseña',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colorTextoSuave),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _confirmarPasswordController,
                    obscureText: _ocultarConfirmar,
                    decoration: InputDecoration(
                      hintText: 'Repite tu contraseña',
                      prefixIcon: const Icon(Icons.lock_outlined, color: colorTextoSuave),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _ocultarConfirmar ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: colorTextoSuave,
                        ),
                        onPressed: () => setState(() => _ocultarConfirmar = !_ocultarConfirmar),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Botón crear cuenta
                  GestureDetector(
                    onTapDown: (_) => setState(() => _pulsado = true),
                    onTapUp: (_) => setState(() => _pulsado = false),
                    onTapCancel: () => setState(() => _pulsado = false),
                    child: AnimatedScale(
                      scale: _pulsado ? 0.95 : 1.0,
                      duration: const Duration(milliseconds: 100),
                      child: ElevatedButton(
                        onPressed: _registrarse,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorPrimario,
                          foregroundColor: colorBlanco,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Crear cuenta',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Enlace a login
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('¿Ya tienes cuenta? ', style: TextStyle(color: colorTextoSuave)),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: const Text(
                            'Iniciar sesión',
                            style: TextStyle(color: colorPrimario, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
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
}

// Curva inferior de la cabecera
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

// Huella decorativa
class _HuellaDecorativa extends StatelessWidget {
  final double size;
  final double opacidad;

  const _HuellaDecorativa({required this.size, required this.opacidad});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacidad,
      child: Icon(Icons.pets, size: size, color: colorBlanco),
    );
  }
}
