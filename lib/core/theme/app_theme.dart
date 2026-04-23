import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary Greens
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF4CAF50);
  static const Color softGreen = Color(0xFFE8F5E9);
  static const Color darkGreen = Color(0xFF1B5E20);

  // Secondary Orange/Amber
  static const Color primaryOrange = Color(0xFFFF8F00);
  static const Color lightOrange = Color(0xFFFFB300);
  static const Color softOrange = Color(0xFFFFF8E1);

  // Neutral
  static const Color background = Color(0xFFF5F7F0);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A2E1A);
  static const Color textMedium = Color(0xFF4A6741);
  static const Color textLight = Color(0xFF8CA88A);
  static const Color divider = Color(0xFFE0EBE0);

  // Semantic
  static const Color profit = Color(0xFF00897B);
  static const Color loss = Color(0xFFE53935);
  static const Color diesel = Color(0xFFFF6F00);
  static const Color earnings = Color(0xFF2E7D32);
  static const Color time = Color(0xFF1565C0);
}

class AppTheme {
  static ThemeData get light {
    final base = GoogleFonts.baloo2TextTheme();
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGreen,
        primary: AppColors.primaryGreen,
        secondary: AppColors.primaryOrange,
        background: AppColors.background,
        surface: AppColors.cardWhite,
      ),
      textTheme: base,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.baloo2(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.baloo2(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardWhite,
        elevation: 4,
        shadowColor: AppColors.primaryGreen.withOpacity(0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.softGreen,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
        labelStyle: GoogleFonts.baloo2(color: AppColors.textMedium),
        hintStyle: GoogleFonts.baloo2(color: AppColors.textLight),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
