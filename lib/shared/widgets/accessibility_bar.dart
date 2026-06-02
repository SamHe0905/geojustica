import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/settings_provider.dart';

class AccessibilityBar extends ConsumerWidget {
  const AccessibilityBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.accessibility_new_rounded,
              size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          _btn(context, 'A-', 'Diminuir letra', () =>
              ref.read(settingsProvider.notifier).decrementFont()),
          const SizedBox(width: 6),
          Text(
            '${(settings.fontScale * 100).round()}%',
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: AppColors.textSecondary),
          ),
          const SizedBox(width: 6),
          _btn(context, 'A+', 'Aumentar letra', () =>
              ref.read(settingsProvider.notifier).incrementFont()),
          const SizedBox(width: 14),
          IconButton(
            tooltip: settings.highContrast ? 'Contraste alto ativado' : 'Alto contraste',
            icon: Icon(
              settings.highContrast
                  ? Icons.contrast_rounded
                  : Icons.contrast_outlined,
              size: 18,
              color: settings.highContrast ? AppColors.primary : AppColors.textSecondary,
            ),
            onPressed: () => ref.read(settingsProvider.notifier).toggleHighContrast(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Widget _btn(BuildContext c, String label, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: AppColors.primary)),
          ),
        ),
      ),
    );
  }
}
