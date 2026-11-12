import 'package:flutter/material.dart';

class Tema {
  static const Color navy = Color(0xFF16202F);
  static const Color navySuave = Color(0xFF23324D);
  static const Color verde = Color(0xFF67B83D);
  static const Color verdeOscuro = Color(0xFF3E8E2D);
  static const Color fondoTenue = Color(0xFFF5F6F8);
  static const Color borde = Color(0xFFE2E8F0);
  static const Color texto = Color(0xFF0F172A);
  static const Color tenue = Color(0xFF64748B);

  static ThemeData get tema => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: fondoTenue,
        colorScheme: ColorScheme.fromSeed(seedColor: verde).copyWith(
          primary: navy,
          secondary: verde,
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: navy,
          elevation: 0,
          centerTitle: false,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: navy,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: navy,
            side: const BorderSide(color: borde),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: borde),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: borde),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: verde, width: 1.6),
          ),
        ),
      );
}