import 'package:flutter/material.dart';

/// Paleta institucional sóbria do GeoJustiça.
///
/// Direção: uma cor institucional (verde) carregando o sistema, neutros de
/// documento, e cor de categoria usada como *legenda* (bate com os pinos do
/// mapa), não como enfeite. As 11 cores de categoria foram reharmonizadas para
/// a mesma faixa de saturação/brilho — só o matiz muda.
class AppColors {
  // ── Verde institucional (a cor que conduz) ──────────────────────────────
  static const Color primary = Color(0xFF0F5A38); // forest
  static const Color primaryLight = Color(0xFF2E9D64);
  static const Color primaryDark = Color(0xFF0A4229); // forest-deep
  static const Color forest = primary;
  static const Color forestDeep = primaryDark;
  static const Color forestTint = Color(0xFFEBF1EC); // fundo suave de ícone/bloco

  // Secundária mantida para pontos específicos, dessaturada para não competir.
  static const Color secondary = Color(0xFF3374B2);
  static const Color secondaryLight = Color(0xFF63A4FF);
  static const Color accent = Color(0xFF9A7A2E); // uso raro

  // ── Neutros de documento ────────────────────────────────────────────────
  static const Color background = Color(0xFFF4F4EF); // paper
  static const Color paper = background;
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceTint = forestTint;
  static const Color chip = Color(0xFFF0F0EA); // chip neutro uniforme da grade

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF16221B); // ink
  static const Color onSurface = Color(0xFF16221B);
  static const Color ink = onBackground;
  static const Color textSecondary = Color(0xFF5E6A63); // muted
  static const Color textMuted = Color(0xFF8A938C); // muted2
  static const Color divider = Color(0xFFE4E7E1); // line

  // ── Semânticas (estado, não decoração) ──────────────────────────────────
  static const Color error = Color(0xFFB3261E);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFB8781F);
  static const Color cardShadow = Color(0x0F16221B);
  static const Color whatsapp = Color(0xFF25D366);

  // ── Cores de categoria — reharmonizadas (= legenda/pinos do mapa) ────────
  static const Color categoryFamilia = Color(0xFF8A50A6);
  static const Color categoryTrabalho = Color(0xFF3374B2);
  static const Color categoryViolencia = Color(0xFFC43A32);
  static const Color categoryConsumidor = Color(0xFFB8781F);
  static const Color categoryMoradia = Color(0xFF3E8E5A);
  static const Color categoryDocumentos = Color(0xFF2C9488);
  static const Color categoryMulher = Color(0xFFC05A93);
  static const Color categoryAposentadoria = Color(0xFF6E7A8A);
  static const Color categorySaude = Color(0xFFC0526A);
  static const Color categoryDenuncias = Color(0xFF7159B0);
  static const Color categoryOutros = Color(0xFF96674A);

  // ── Gradientes (mantidos por compat; uso desencorajado no redesign) ──────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryDark, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [primaryDark, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
