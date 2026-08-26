import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'geo_icon.dart';

/// Estado de tela cheia (vazio ou erro) sempre com o próximo passo.
///
/// Um estado vazio é um convite para agir; um erro explica o que houve e como
/// resolver — na voz do app, sem pedir desculpas nem ser vago.
class GeoStateView extends StatelessWidget {
  final String iconName;
  final Color accent;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const GeoStateView({
    super.key,
    required this.iconName,
    required this.accent,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  /// Vazio: nada encontrado para a busca.
  factory GeoStateView.empty({
    required String title,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
    String iconName = 'search',
  }) =>
      GeoStateView(
        iconName: iconName,
        accent: AppColors.forest,
        title: title,
        message: message,
        actionLabel: actionLabel,
        onAction: onAction,
      );

  /// Erro: algo falhou (rede etc.).
  factory GeoStateView.error({
    required VoidCallback onRetry,
    String title = 'Sem conexão',
    String message = 'Não foi possível carregar agora. Verifique sua internet e toque para tentar de novo.',
    String actionLabel = 'Tentar de novo',
  }) =>
      GeoStateView(
        iconName: 'warning',
        accent: AppColors.error,
        title: title,
        message: message,
        actionLabel: actionLabel,
        onAction: onRetry,
      );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(child: GeoIcon(iconName, color: accent, size: 28)),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ink),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                minimumSize: const Size(0, 48),
                padding: const EdgeInsets.symmetric(horizontal: 22),
              ),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
