import 'package:flutter/material.dart';

class TemaSaude {
  static const teal = Color(0xFF0D9488);
  static const fonteMinima = 18.0;
  static const alvo = 56.0;

  static ThemeData get theme {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: teal,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
    );
    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: teal,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(alvo),
          backgroundColor: teal,
          textStyle: const TextStyle(fontSize: fonteMinima, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(alvo),
          textStyle: const TextStyle(fontSize: fonteMinima),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        labelStyle: TextStyle(fontSize: fonteMinima),
        hintStyle: TextStyle(fontSize: fonteMinima),
      ),
    );
  }
}
