import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/settings_provider.dart';
import 'geo_icon.dart';

/// Barra de acessibilidade: tamanho do texto e alto contraste, com lugar
/// visível e rótulos claros para quem tem baixa visão ou pouco letramento.
class AccessibilityBar extends ConsumerWidget {
  const AccessibilityBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: const BoxDecoration(
        color: AppColors.forestTint,
        border: Border(bottom: BorderSide(color: Color(0x240F5A38))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text('Texto',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color: AppColors.forest,
                  )),
              const SizedBox(width: 8),
              _sq(context, 'A', 12, 'Diminuir letra',
                  () => ref.read(settingsProvider.notifier).decrementFont()),
              const SizedBox(width: 6),
              _sq(context, 'A', 16, 'Aumentar letra',
                  () => ref.read(settingsProvider.notifier).incrementFont()),
            ],
          ),
          _pill(
            context,
            iconName: 'contrast',
            label: 'Contraste',
            active: settings.highContrast,
            tooltip: settings.highContrast ? 'Contraste alto ativado' : 'Alto contraste',
            onTap: () => ref.read(settingsProvider.notifier).toggleHighContrast(),
          ),
        ],
      ),
    );
  }

  Widget _sq(BuildContext c, String label, double size, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            width: 32,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.28)),
            ),
            child: Text(label,
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: size, color: AppColors.primary)),
          ),
        ),
      ),
    );
  }

  Widget _pill(BuildContext c,
      {required String iconName,
      required String label,
      required bool active,
      required String tooltip,
      required VoidCallback onTap}) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: active ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withValues(alpha: active ? 1 : 0.28)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GeoIcon(iconName, size: 16, color: active ? Colors.white : AppColors.primary),
                const SizedBox(width: 5),
                Text(label,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: active ? Colors.white : AppColors.primary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
