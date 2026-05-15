import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Colores
const colorPrimario     = Color(0xFF00897B);
const colorAdoptar      = Color(0xFF00796B);
const colorPerdidas     = Color(0xFFE05C2A); 
const colorReportar     = Color(0xFF5FAD41); 
const colorFondo        = Color(0xFFF5F5F5);
const colorBlanco       = Color(0xFFFFFFFF);
const colorTexto        = Color(0xFF1A1A1A);
const colorTextoSuave   = Color(0xFF757575);
const colorError        = Color(0xFFD32F2F);
const colorAcento       = Color(0xFFB2DFDB);

// Borde usado en los inputs
final bordeInput = OutlineInputBorder(
  borderRadius: BorderRadius.circular(12),
  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
);

// Tema principal de la app
final temaApp = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: colorPrimario,
    primary: colorPrimario,
    secondary: colorAdoptar,
    error: colorError,
    surface: colorFondo,
  ),
  scaffoldBackgroundColor: colorFondo,
  fontFamily: 'Roboto',

  // Barra superior
  appBarTheme: const AppBarTheme(
    backgroundColor: colorPrimario,
    foregroundColor: colorBlanco,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: colorBlanco,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  ),

  // Botones principales
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: colorPrimario,
      foregroundColor: colorBlanco,
      minimumSize: const Size(double.infinity, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),

  // Campos de texto
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: colorBlanco,
    border: bordeInput,
    enabledBorder: bordeInput,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: colorPrimario, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    hintStyle: const TextStyle(color: colorTextoSuave),
  ),

  // Tarjetas
  cardTheme: CardThemeData(
    elevation: 2,
    color: colorBlanco,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
);

// Controla si esta activo el modo oscuro
final modoOscuroProvider = StateProvider<bool>((ref) => false);
