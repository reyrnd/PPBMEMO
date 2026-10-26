import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF2A2926);
  static const Color primary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF5F6368);
  static const Color surface = Color(0xFFF4F5F7);
  static const Color editorToolbarBackground = Color(0xFFF4F5F7);
  static const Color viewerBackground = Color(0xFF111111);
  static const Color viewerForeground = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE0E0E0);
  static const Color bgPill = Color(0xFFF1F5F9);

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

  static InputDecoration pillInput({
    String? hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    OutlineInputBorder border([Color? color]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: color == null
              ? BorderSide.none
              : BorderSide(color: color, width: 1),
        );

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF4F5F7),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: border(),
      enabledBorder: border(),
      focusedBorder: border(textPrimary),
      errorBorder: border(Colors.redAccent),
      focusedErrorBorder: border(Colors.redAccent),
    );
  }
}
