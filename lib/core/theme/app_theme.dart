import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Tema institucional sóbrio: tipografia Inter com hierarquia por peso/tamanho,
/// cantos contidos (14–16), sombra sutil e verde institucional conduzindo.
class AppTheme {
  static ThemeData get light {
    final base = GoogleFonts.interTextTheme();
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        onPrimary: AppColors.onPrimary,
        onSecondary: AppColors.onSecondary,
        onSurface: AppColors.onSurface,
        brightness: Brightness.light,
      ),
      textTheme: base.copyWith(
        displayLarge: GoogleFonts.inter(fontSize: 27, fontWeight: FontWeight.w800, letterSpacing: -0.6, color: AppColors.ink),
        displayMedium: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.4, color: AppColors.ink),
        titleLarge: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.3, color: AppColors.ink),
        titleMedium: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.ink),
        bodyLarge: GoogleFonts.inter(fontSize: 15.5, fontWeight: FontWeight.w500, color: AppColors.ink),
        bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.ink),
        labelLarge: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.onPrimary),
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.forestDeep,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
          color: AppColors.onPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shadowColor: AppColors.cardShadow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.divider),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 15.5),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
