import 'package:flutter/material.dart';

class DgiColors {
  DgiColors._();
  static const primary = Color(0xFF0D47A1);
  static const darkBlue = Color(0xFF07336B);
  static const background = Color(0xFFF4F6FA);
  static const white = Color(0xFFFFFFFF);
  static const success = Color(0xFF1E9E55);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFE91E4D);
  static const purple = Color(0xFF7C3AC8);
  static const turquoise = Color(0xFF08A0B5);
}

ThemeData buildDgiTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: DgiColors.primary,
    brightness: Brightness.light,
  ).copyWith(primary: DgiColors.primary, error: DgiColors.error);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: DgiColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: DgiColors.white,
      foregroundColor: DgiColors.darkBlue,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: DgiColors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: DgiColors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
    ),
  );
}
