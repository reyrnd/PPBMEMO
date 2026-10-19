import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF2A2926);
  static const Color textSecondary = Color(0xFF5C5750);
  static const Color surface = Color(0xFFF5F4F1);
  static const Color border = Color(0xFFE2DDD0);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: textPrimary,
        brightness: Brightness.light,
        surface: background,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: textPrimary,
            width: 1.2,
          ),
        ),
      ),
    );
  }
}
