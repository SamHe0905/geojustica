import 'package:flutter/material.dart';

// Paleta refinada baseada nas cores do Mato Grosso do Sul
class AppColors {
  static const Color primary = Color(0xFF1B7A4A);
  static const Color primaryLight = Color(0xFF4FB37C);
  static const Color primaryDark = Color(0xFF0A5732);
  static const Color secondary = Color(0xFF1976D2);
  static const Color secondaryLight = Color(0xFF63A4FF);
  static const Color accent = Color(0xFFFFB300);
  static const Color background = Color(0xFFF7FAF7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceTint = Color(0xFFE8F2EB);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF1B2820);
  static const Color onSurface = Color(0xFF1B2820);
  static const Color textSecondary = Color(0xFF5C6B66);
  static const Color textMuted = Color(0xFF8A9690);
  static const Color divider = Color(0xFFE0E8E3);
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57C00);
  static const Color cardShadow = Color(0x14000000);
  static const Color whatsapp = Color(0xFF25D366);

  // Cores de categoria mais vibrantes
  static const Color categoryFamilia = Color(0xFF9C27B0);
  static const Color categoryTrabalho = Color(0xFF1E88E5);
  static const Color categoryViolencia = Color(0xFFE53935);
  static const Color categoryConsumidor = Color(0xFFF57C00);
  static const Color categoryMoradia = Color(0xFF43A047);
  static const Color categoryDocumentos = Color(0xFF00897B);
  static const Color categoryMulher = Color(0xFFEC407A);
  static const Color categoryAposentadoria = Color(0xFF546E7A);
  static const Color categorySaude = Color(0xFFE53935);
  static const Color categoryDenuncias = Color(0xFF5E35B1);
  static const Color categoryOutros = Color(0xFF6D4C41);

  // Gradientes prontos
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryDark, primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0A5732), Color(0xFF1B7A4A), Color(0xFF2E9D64)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
