import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.light.primary,
      ),
      scaffoldBackgroundColor: AppColors.light.background,
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: AppColors.light.onSurface,
        displayColor: AppColors.light.onSurface,
      ),
      extensions: const <ThemeExtension<dynamic>>[
        AppColors.light,
      ],
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.dark.primary,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: AppColors.dark.background,
      textTheme: GoogleFonts.outfitTextTheme(ThemeData(brightness: Brightness.dark).textTheme).apply(
        bodyColor: AppColors.dark.onSurface,
        displayColor: AppColors.dark.onSurface,
      ),
      extensions: const <ThemeExtension<dynamic>>[
        AppColors.dark,
      ],
    );
  }
}
