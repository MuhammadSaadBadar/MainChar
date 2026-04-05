import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFFD394FF);
  static const Color primaryDim = Color(0xFFAA30FA);
  static const Color secondary = Color(0xFFC3F400);
  static const Color secondaryDim = Color(0xFFB7E500);
  static const Color tertiary = Color(0xFFA1FAFF);

  // Neutral Colors
  static const Color background = Color(0xFF0E0E0E);
  static const Color surface = Color(0xFF0E0E0E);
  static const Color surfaceContainer = Color(0xFF1A1A1A);
  static const Color surfaceContainerHigh = Color(0xFF20201F);
  static const Color surfaceContainerHighest = Color(0xFF262626);
  static const Color surfaceBright = Color(0xFF2C2C2C);

  // Accent & Status
  static const Color onSurface = Color(0xFFFFFFFF);
  static const Color onSurfaceVariant = Color(0xFFADAAAA);
  static const Color outline = Color(0xFF767575);
  static const Color error = Color(0xFFFF6E84);

  // Custom Gradients
  static const List<Color> bgGradient = [Color(0xFF0E0E0E), Color(0xFF1A1A1A)];
}

class AppTextStyles {
  // Headlines - Epilogue
  static TextStyle headline(
    double size, {
    Color color = AppColors.onSurface,
    FontWeight weight = FontWeight.w900,
    bool italic = false,
    double? letterSpacing,
  }) {
    return GoogleFonts.epilogue(
      fontSize: size,
      color: color,
      fontWeight: weight,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      letterSpacing: letterSpacing ?? -1.0,
    );
  }

  // Body - Plus Jakarta Sans
  static TextStyle body(
    double size, {
    Color color = AppColors.onSurface,
    FontWeight weight = FontWeight.w400,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      color: color,
      fontWeight: weight,
    );
  }

  // Labels/Small UI - Space Grotesk
  static TextStyle label(
    double size, {
    Color color = AppColors.onSurfaceVariant,
    FontWeight weight = FontWeight.w500,
    double letterSpacing = 0.0,
  }) {
    return GoogleFonts.spaceGrotesk(
      fontSize: size,
      color: color,
      fontWeight: weight,
      letterSpacing: letterSpacing,
    );
  }
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        error: AppColors.error,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.headline(48),
        bodyLarge: AppTextStyles.body(16),
        labelLarge: AppTextStyles.label(12, letterSpacing: 0.1),
      ),
      // Custom extensions could go here
    );
  }
}
