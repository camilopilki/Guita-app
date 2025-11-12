import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildGuitaTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF247BA0));
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    // Aplica Comfortaa globalmente
    textTheme: GoogleFonts.comfortaaTextTheme(),
    cardTheme: const CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
    ),
  );
}
