import 'package:flutter/material.dart';
import '../../../models/institution.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/category_style.dart';
import '../../../shared/widgets/geo_icon.dart';

/// Card de categoria: superfície branca com hairline, chip neutro uniforme e a
/// cor da categoria apenas no ícone (calma na grade, coerência com a legenda).
class CategoryButton extends StatefulWidget {
  final InstitutionCategory category;
  final VoidCallback onTap;

  const CategoryButton({super.key, required this.category, required this.onTap});

  @override
  State<CategoryButton> createState() => _CategoryButtonState();
}

class _CategoryButtonState extends State<CategoryButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: widget.onTap,
          splashColor: AppColors.primary.withValues(alpha: 0.06),
          highlightColor: AppColors.primary.withValues(alpha: 0.04),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _hover ? AppColors.primary : AppColors.divider,
                width: 1,
              ),
              boxShadow: _hover
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.16),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.chip,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: GeoIcon(widget.category.iconName, color: widget.category.color, size: 24),
                  ),
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: Text(
                    widget.category.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
