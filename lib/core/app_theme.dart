import 'package:flutter/material.dart';

class AppTheme {
  // --- FIGMA / INDEX.CSS DESIGN SYSTEM TOKENS ---
  static const String fontFamily = 'Manrope';
  static const List<String> fontFamilyFallback = [
    'Segoe UI',
    'Inter',
    'Roboto',
    'sans-serif',
  ];

  static const Color page = Color(0xFFDED9CD);
  static const Color canvas = Color(0xFFF0EDE4);
  static const Color ink = Color(0xFF2A2926);
  static const Color muted = Color(0xFF5C5750);
  static const Color textPrimary = ink;
  static const Color textSecondary = muted;
  static const Color background = canvas;
  static const Color primary = ink;
  static const Color border = line;
  static const Color editorToolbarBackground = surface;
  static const Color faint = Color(0xFF9A948A);
  static const Color line = Color(0xFFE2DDD0);
  static const Color soft = Color(0xFFE8E3D8);
  static const Color surface = Color(0xFFF7F5EF);

  // Accents & Tags
  static const Color caramel = Color(0xFFB76D42);
  static const Color danger = Color(0xFFA94335);
  static const Color dangerSoft = Color(0xFFF3D8D2);
  static const Color coral = danger;
  static const Color blush = dangerSoft;
  static const Color olive = Color(0xFF687157);
  static const Color plum = Color(0xFF75647D);
  static const Color peach = Color(0xFFF2DED0);
  static const Color mint = Color(0xFFDCE4D5);
  static const Color lilac = Color(0xFFE4DCE7);

  // Helper warna putih murni untuk field/card internal
  static const Color whiteBackgroundField = Colors.white;

  // --- FIGMA SHADOWS ---
  static const BoxShadow shadowSoft = BoxShadow(
    color: Color(0x0E2A2926), // rgba(42, 41, 38, 0.055)
    offset: Offset(0, 4),
    blurRadius: 18,
  );

  static const BoxShadow shadowCard = BoxShadow(
    color: Color(0x1F2A2926), // rgba(42, 41, 38, 0.12)
    offset: Offset(0, 14),
    blurRadius: 30,
  );

  static const BoxShadow shadowNav = BoxShadow(
    color: Color(0x3D2A2926), // rgba(42, 41, 38, 0.24)
    offset: Offset(0, 16),
    blurRadius: 35,
  );

  static TextStyle style({
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w600,
    Color color = ink,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
    );
  }

  // --- FLUTTER MATERIAL THEME CONFIGURATION ---
  static ThemeData get lightTheme {
    final baseTextTheme = ThemeData.light().textTheme.apply(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
          bodyColor: ink,
          displayColor: ink,
        );

    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      scaffoldBackgroundColor: canvas,
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
        ),
        displayMedium: baseTextTheme.displayMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.6,
        ),
        displaySmall: baseTextTheme.displaySmall?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        titleSmall: baseTextTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        labelMedium: baseTextTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        labelSmall: baseTextTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: ink,
        brightness: Brightness.light,
        primary: ink,
        surface: canvas,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: canvas,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: style(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: ink,
          letterSpacing: -0.4,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: style(fontSize: 12, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: style(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        contentTextStyle: style(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        isDense: false,
        hintStyle: style(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: faint,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
      ),
    );
  }
}

/// DeadlineBadge widget matching `DeadlineBadge` from `App.tsx`
class DeadlineBadge extends StatelessWidget {
  final String date;
  final bool completed;
  final VoidCallback? onTap;

  const DeadlineBadge({
    super.key,
    required this.date,
    this.completed = false,
    this.onTap,
  });

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String formatShortDate(String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return '${_months[parsed.month - 1]} ${parsed.day}';
  }

  @override
  Widget build(BuildContext context) {
    if (date.trim().isEmpty && !completed) return const SizedBox.shrink();

    Color bg = AppTheme.peach;
    Color fg = AppTheme.caramel;
    String label = 'Due $date';

    if (completed) {
      bg = AppTheme.mint;
      fg = AppTheme.olive;
      label = 'Completed';
    } else {
      final parsed = DateTime.tryParse(date);
      if (parsed != null) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final due = DateTime(parsed.year, parsed.month, parsed.day);
        final diff = due.difference(today).inDays;
        final formatted = formatShortDate(date);
        if (diff < 0) {
          bg = AppTheme.dangerSoft;
          fg = AppTheme.danger;
          label = 'Overdue · $formatted';
        } else if (diff == 0) {
          bg = AppTheme.caramel;
          fg = Colors.white;
          label = 'Due today';
        } else {
          bg = AppTheme.peach;
          fg = AppTheme.caramel;
          label = 'Due $formatted';
        }
      } else if (date.toLowerCase().contains('overdue')) {
        bg = AppTheme.dangerSoft;
        fg = AppTheme.danger;
        label = date;
      } else if (date.toLowerCase().contains('today')) {
        bg = AppTheme.caramel;
        fg = Colors.white;
        label = 'Due today';
      } else if (date.toLowerCase().contains('completed')) {
        bg = AppTheme.mint;
        fg = AppTheme.olive;
        label = 'Completed';
      } else {
        label = date.startsWith('Due') ? date : 'Due $date';
      }
    }

    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today_rounded, size: 10, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return badge;
    return GestureDetector(onTap: onTap, child: badge);
  }
}
