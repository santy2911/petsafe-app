import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- PALETA DE COLORES OFICIAL PETSAFE ---

// Principales (Teal)
const colorPrimario       = Color(0xFF26C6A6);
const colorAdoptar        = Color(0xFF26C6A6);
const colorPrimarioLight  = Color(0xFFE8F8F5);

// Acentos (Pink)
const colorAcentoRosa     = Color(0xFFFF6B8A);
const colorPerdidas       = Color(0xFFFF6B8A);
const colorReportar       = Color(0xFFFF6B8A);
const colorAcentoLight    = Color(0xFFFFF0F3);

// Gamificación (Purple)
const colorXP             = Color(0xFF5C6BC0);
const colorXPLight        = Color(0xFFECEFFE);

// Neutros y Superficies
const colorFondo          = Color(0xFFF5F7FA);
const colorBlanco         = Color(0xFFFFFFFF);
const colorSurface        = Color(0xFFFFFFFF);
const colorSidebar        = Color(0xFF1A1A2E);

// Texto
const colorTexto          = Color(0xFF0F172A);
const colorTextoSuave     = Color(0xFF8A8A9A);

// Otros
const colorError          = Color(0xFFEF4444);
const colorAcento         = Color(0xFFF59E0B); // Ámbar

// --- ESTILOS COMPARTIDOS ---

final sombraSuave = [
  BoxShadow(
    color: const Color(0xFF1A1A2E).withValues(alpha: 0.06),
    blurRadius: 24,
    offset: const Offset(0, 8),
  ),
];

// --- TEMA DATA ---

final temaApp = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: colorPrimario,
    primary: colorPrimario,
    onPrimary: colorBlanco,
    secondary: colorXP,
    onSecondary: colorBlanco,
    error: colorError,
    surface: colorSurface,
    onSurface: colorTexto,
  ),
  scaffoldBackgroundColor: colorFondo,
  fontFamily: 'Outfit',

  appBarTheme: const AppBarTheme(
    backgroundColor: colorFondo,
    foregroundColor: colorTexto,
    elevation: 0,
    centerTitle: true,
    scrolledUnderElevation: 0,
    titleTextStyle: TextStyle(
      color: colorTexto,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      fontFamily: 'Outfit',
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: colorPrimario,
      foregroundColor: colorBlanco,
      minimumSize: const Size(double.infinity, 56),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  ),

  cardTheme: CardThemeData(
    elevation: 0,
    color: colorSurface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
      side: BorderSide(color: colorTexto.withValues(alpha: 0.12), width: 1.2),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: colorBlanco,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: colorPrimario, width: 2)),
    hintStyle: const TextStyle(color: colorTextoSuave, fontSize: 15),
  ),
);

final modoOscuroProvider = StateProvider<bool>((ref) => false);
