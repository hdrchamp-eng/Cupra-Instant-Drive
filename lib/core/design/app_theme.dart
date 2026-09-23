import 'package:flutter/material.dart';

abstract final class AppColors {
  static const ink = Color(0xFF090F1D);
  static const surface = Color(0xFF131D2E);
  static const surfaceHigh = Color(0xFF1B2940);
  static const copper = Color(0xFFC47B57);
  static const cream = Color(0xFFF5F2ED);
  static const muted = Color(0xFFA8B0BE);
  static const line = Color(0xFF2B3A51);
  static const success = Color(0xFF4CCB91);
  static const warning = Color(0xFFFFC260);
  static const error = Color(0xFFFF5C73);
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.copper,
    brightness: Brightness.dark,
    surface: AppColors.surface,
  );
  return ThemeData(
    brightness: Brightness.dark,
    colorScheme: scheme.copyWith(
      primary: AppColors.copper,
      secondary: AppColors.copper,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.ink,
    fontFamily: 'Arial',
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 52,
        height: .98,
        fontWeight: FontWeight.w900,
        letterSpacing: -2.2,
        color: AppColors.cream,
      ),
      displayMedium: TextStyle(
        fontSize: 38,
        height: 1.03,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.4,
        color: AppColors.cream,
      ),
      headlineLarge: TextStyle(
        fontSize: 30,
        height: 1.08,
        fontWeight: FontWeight.w800,
        letterSpacing: -.7,
        color: AppColors.cream,
      ),
      headlineMedium: TextStyle(
        fontSize: 23,
        height: 1.12,
        fontWeight: FontWeight.w800,
        letterSpacing: -.4,
        color: AppColors.cream,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.cream,
      ),
      titleMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.cream,
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: AppColors.cream),
      bodyMedium: TextStyle(fontSize: 14, height: 1.45, color: AppColors.muted),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        letterSpacing: .2,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.ink,
      foregroundColor: AppColors.cream,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.line),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      labelStyle: const TextStyle(color: AppColors.muted),
      hintStyle: const TextStyle(color: Color(0xFF6F7A8D)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.copper, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.copper,
        foregroundColor: AppColors.ink,
        minimumSize: const Size(48, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.cream,
        minimumSize: const Size(48, 52),
        side: const BorderSide(color: AppColors.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Color(0xFF0C1423),
      indicatorColor: Color(0x33C47B57),
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
    ),
    dividerColor: AppColors.line,
    useMaterial3: true,
  );
}
