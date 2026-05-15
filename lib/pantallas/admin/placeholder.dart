import 'package:flutter/material.dart';

class AdminPlaceholder extends StatelessWidget {
  final String title;
  const AdminPlaceholder({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('Pantalla de $title en construcción')),
    );
  }
}
