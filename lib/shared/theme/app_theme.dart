import 'package:flutter/material.dart';
import '../../app/constants.dart';

/// Centralized theme configuration following Apple HIG and brand guidelines.
class AppTheme {
  AppTheme._();

  static const Color primaryBlack = Color(AppConstants.primaryBlack);
  static const Color accentGold = Color(AppConstants.accentGold);
  static const Color accentRed = Color(AppConstants.accentRed);
  static const Color textWhite = Color(AppConstants.textWhite);
  static const Color surfaceDark = Color(AppConstants.surfaceDark);
  static const Color errorRed = Color(AppConstants.errorRed);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryBlack,
      scaffoldBackgroundColor: primaryBlack,
      colorScheme: const ColorScheme.dark(
        primary: accentGold,
        secondary: accentRed,
        surface: surfaceDark,
        error: errorRed,
        onPrimary: primaryBlack,
        onSecondary: textWhite,
        onSurface: textWhite,
        onError: primaryBlack,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlack,
        foregroundColor: textWhite,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textWhite,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          color: textWhite,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: textWhite,
          fontSize: 17,
          height: 1.4,
        ),
        bodyMedium: TextStyle(
          color: textWhite,
          fontSize: 15,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          color: accentGold,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentGold,
          foregroundColor: primaryBlack,
          minimumSize: const Size(200, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
