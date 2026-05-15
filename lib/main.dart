import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'rutas.dart';
import 'tema.dart';

// Inicio de la app
void main() {
  runApp(const ProviderScope(child: MiApp()));
}

// Widget principal
class MiApp extends ConsumerWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modoOscuro = ref.watch(modoOscuroProvider);

    return MaterialApp.router(
      title: 'PetSafe',
      debugShowCheckedModeBanner: false,
      routerConfig: rutasApp,
      themeMode: modoOscuro ? ThemeMode.dark : ThemeMode.light,
      theme: temaApp,
      // Tema oscuro basico
      darkTheme: ThemeData(
        colorSchemeSeed: colorPrimario,
        brightness: Brightness.dark,
      ),
    );
  }
}
