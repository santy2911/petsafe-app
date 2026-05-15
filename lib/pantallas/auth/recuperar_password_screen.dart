import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../tema.dart';
import '../../providers/auth_provider.dart';

// Pantalla para recuperar password
class RecuperarPasswordScreen extends ConsumerStatefulWidget {
  const RecuperarPasswordScreen({super.key});

  @override
  ConsumerState<RecuperarPasswordScreen> createState() => _RecuperarPasswordScreenState();
}

class _RecuperarPasswordScreenState extends ConsumerState<RecuperarPasswordScreen> {
  final _emailController = TextEditingController();
  bool _enviado = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Muestra errores del formulario
  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: colorError),
    );
  }

  // Valida el email y muestra la confirmacion
  Future<void> _enviarEnlace() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _mostrarError('Por favor introduce tu email');
      return;
    }
    if (!email.contains('@')) {
      _mostrarError('Introduce un email válido');
      return;
    }

    try {
      await ref.read(authProvider.notifier).recuperarPassword(email);
      if (mounted) setState(() => _enviado = true);
    } catch (e) {
      _mostrarError('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

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
                          'Recuperar contraseña',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: colorBlanco),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Te enviaremos un enlace de recuperación',
                          style: TextStyle(fontSize: 14, color: colorBlanco),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Formulario o confirmación según el estado
          Expanded(
            child: _enviado
                ? const _PantallaConfirmacion()
                : _Formulario(
                    emailController: _emailController, 
                    onEnviar: _enviarEnlace,
                    cargando: authState.cargando,
                  ),
          ),
        ],
      ),
    );
  }
}

// Formulario para escribir el email
class _Formulario extends StatelessWidget {
  final TextEditingController emailController;
  final VoidCallback onEnviar;
  final bool cargando;

  const _Formulario({required this.emailController, required this.onEnviar, required this.cargando});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Email',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colorTextoSuave),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            enabled: !cargando,
            decoration: const InputDecoration(
              hintText: 'correo@ejemplo.com',
              prefixIcon: Icon(Icons.email_outlined, color: colorTextoSuave),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: cargando ? null : onEnviar,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorPrimario,
              foregroundColor: colorBlanco,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: cargando 
                ? const CircularProgressIndicator(color: colorBlanco)
                : const Text(
                    'Enviar enlace',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onTap: () => context.go('/login'),
              child: const Text(
                'Volver al inicio de sesión',
                style: TextStyle(color: colorTextoSuave, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Pantalla despues de enviar el email
class _PantallaConfirmacion extends StatelessWidget {
  const _PantallaConfirmacion();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.mark_email_read_outlined, size: 80, color: colorPrimario),
          const SizedBox(height: 24),
          const Text(
            '¡Email enviado!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorTexto),
          ),
          const SizedBox(height: 8),
          const Text(
            'Revisa tu bandeja de entrada y sigue las instrucciones para restablecer tu contraseña.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colorTextoSuave, height: 1.5),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.go('/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorPrimario,
              foregroundColor: colorBlanco,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Volver al login',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
