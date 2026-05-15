import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../tema.dart';

// Pantalla de login
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _ocultarPassword = true;
  bool _pulsado = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Muestra errores del formulario
  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: colorError),
    );
  }

  // Comprueba los datos del login
  void _iniciarSesion() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
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
              padding: const EdgeInsets.only(top: 80, bottom: 60),
              color: colorPrimario,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(top: -10, left: 30, child: _HuellaDecorativa(size: 60, opacidad: 0.15)),
                  Positioned(top: 10, right: 20, child: _HuellaDecorativa(size: 80, opacidad: 0.12)),
                  Positioned(bottom: 30, right: 50, child: _HuellaDecorativa(size: 45, opacidad: 0.10)),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: const BoxDecoration(color: colorBlanco, shape: BoxShape.circle),
                        child: const Icon(Icons.pets, color: colorPrimario, size: 48),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'PetSafe',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colorBlanco),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tu plataforma de adopción',
                        style: TextStyle(fontSize: 14, color: colorBlanco),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Formulario de login
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Iniciar sesión',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorTexto),
                  ),
                  const SizedBox(height: 28),

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
                      hintText: 'a@gmail.com',
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
                      hintText: '••••••••',
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

                  // Olvidaste contraseña
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.go('/recuperar-password'),
                      child: const Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(color: colorPrimario, fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Botón iniciar sesión
                  GestureDetector(
                    onTapDown: (_) => setState(() => _pulsado = true),
                    onTapUp: (_) => setState(() => _pulsado = false),
                    onTapCancel: () => setState(() => _pulsado = false),
                    child: AnimatedScale(
                      scale: _pulsado ? 0.95 : 1.0,
                      duration: const Duration(milliseconds: 100),
                      child: ElevatedButton(
                        onPressed: _iniciarSesion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorPrimario,
                          foregroundColor: colorBlanco,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Iniciar sesión',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Enlace a registro
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('¿No tienes cuenta? ', style: TextStyle(color: colorTextoSuave)),
                        GestureDetector(
                          onTap: () => context.go('/registro'),
                          child: const Text(
                            'Regístrate',
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
