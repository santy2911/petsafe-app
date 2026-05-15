import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../tema.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _ocultarPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, rellena todos los campos')),
      );
      return;
    }

    await ref.read(authProvider.notifier).login(email, pass);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final size = MediaQuery.sizeOf(context);
    final isDesktop = size.width > 900;
    ref.listen(authProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: colorError),
        );
      }
    });

    return Scaffold(
      backgroundColor: colorFondo,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isDesktop ? 40 : 20,
                    8,
                    isDesktop ? 40 : 20,
                    8,
                  ),
                  child: Center(
                    child: Container(
                      width: isDesktop ? 420 : null,
                      constraints: BoxConstraints(maxWidth: isDesktop ? 420 : double.infinity),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: colorPrimario.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.pets, color: colorPrimario, size: 40),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Bienvenido a PetSafe',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorTexto),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Tu plataforma de gestión de refugios',
                            style: TextStyle(color: colorTextoSuave, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Iniciar Sesión',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 18),
                                  const Text('Email', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: const InputDecoration(
                                      hintText: 'ejemplo@correo.com',
                                      prefixIcon: Icon(Icons.email_outlined, size: 20),
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  const Text('Contraseña', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: _passwordController,
                                    obscureText: _ocultarPassword,
                                    decoration: InputDecoration(
                                      hintText: '••••••••',
                                      prefixIcon: const Icon(Icons.lock_outlined, size: 20),
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _ocultarPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                          size: 20,
                                        ),
                                        onPressed: () => setState(() => _ocultarPassword = !_ocultarPassword),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      onPressed: () => context.go('/recuperar-password'),
                                      child: const Text('¿Has olvidado tu contraseña?', style: TextStyle(fontSize: 12)),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  ElevatedButton(
                                    onPressed: authState.cargando ? null : _iniciarSesion,
                                    child: authState.cargando
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                          )
                                        : const Text('Entrar'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('¿No tienes cuenta? ', style: TextStyle(color: colorTextoSuave, fontSize: 13)),
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () => context.go('/registro'),
                                child: const Text('Regístrate ahora', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Sugerencia: admin@petsafe.es para entrar como admin',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colorTextoSuave.withValues(alpha: 0.9),
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
