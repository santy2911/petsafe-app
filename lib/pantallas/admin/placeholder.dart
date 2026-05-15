import 'package:flutter/material.dart';
import '../../tema.dart';
import '../../widgets/boton_notificaciones.dart';

class AdminPlaceholder extends StatelessWidget {
  final String title;
  const AdminPlaceholder({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        title: Text(title),
        actions: const [
          BotonNotificaciones(),
          SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Pantalla de $title en construcción',
            textAlign: TextAlign.center,
            style: const TextStyle(color: colorTextoSuave, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
