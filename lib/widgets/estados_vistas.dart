import 'package:flutter/material.dart';
import '../tema.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String? subtitulo;
  final String? labelBoton;
  final VoidCallback? onAccion;

  const EmptyStateWidget({
    super.key,
    required this.icono,
    required this.titulo,
    this.subtitulo,
    this.labelBoton,
    this.onAccion,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: sombraSuave,
              ),
              child: Icon(icono, size: 64, color: colorTextoSuave.withValues(alpha: 0.3)),
            ),
            const SizedBox(height: 24),
            Text(titulo, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorTexto)),
            if (subtitulo != null) ...[
              const SizedBox(height: 8),
              Text(subtitulo!, textAlign: TextAlign.center, style: const TextStyle(color: colorTextoSuave, fontSize: 14)),
            ],
            if (labelBoton != null && onAccion != null) ...[
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onAccion,
                style: ElevatedButton.styleFrom(minimumSize: const Size(200, 48)),
                child: Text(labelBoton!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LoadingStateWidget extends StatefulWidget {
  final int count;
  const LoadingStateWidget({super.key, this.count = 3});

  @override
  State<LoadingStateWidget> createState() => _LoadingStateWidgetState();
}

class _LoadingStateWidgetState extends State<LoadingStateWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: widget.count,
      itemBuilder: (context, index) => FadeTransition(
        opacity: _animation,
        child: Container(
          height: 120,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Row(
            children: [
              Container(width: 100, decoration: const BoxDecoration(color: Color(0xFFF1F5F9), borderRadius: BorderRadius.horizontal(left: Radius.circular(24)))),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 20, width: 120, color: const Color(0xFFF1F5F9)),
                    const SizedBox(height: 8),
                    Container(height: 15, width: 80, color: const Color(0xFFF1F5F9)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorStateWidget extends StatelessWidget {
  final String mensaje;
  final VoidCallback onRetry;

  const ErrorStateWidget({super.key, required this.mensaje, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: colorError),
            const SizedBox(height: 24),
            const Text('¡Ups! Algo salió mal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(mensaje, textAlign: TextAlign.center, style: const TextStyle(color: colorTextoSuave)),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
