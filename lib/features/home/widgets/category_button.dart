import 'package:flutter/material.dart';
import '../../../models/institution.dart';
import '../../../core/constants/app_colors.dart';

class CategoryButton extends StatefulWidget {
  final InstitutionCategory category;
  final VoidCallback onTap;

  const CategoryButton({super.key, required this.category, required this.onTap});

  @override
  State<CategoryButton> createState() => _CategoryButtonState();
}

class _CategoryButtonState extends State<CategoryButton> {
  bool _hover = false;

  IconData get _icon {
    switch (widget.category) {
      case InstitutionCategory.familia: return Icons.family_restroom_rounded;
      case InstitutionCategory.trabalho: return Icons.work_rounded;
      case InstitutionCategory.violenciaDomestica: return Icons.shield_rounded;
      case InstitutionCategory.consumidor: return Icons.shopping_bag_rounded;
      case InstitutionCategory.moradia: return Icons.home_rounded;
      case InstitutionCategory.documentos: return Icons.badge_rounded;
      case InstitutionCategory.direitosMulher: return Icons.female_rounded;
      case InstitutionCategory.aposentadoria: return Icons.elderly_rounded;
      case InstitutionCategory.outros: return Icons.help_rounded;
    }
  }

  Color get _color {
    switch (widget.category) {
      case InstitutionCategory.familia: return AppColors.categoryFamilia;
      case InstitutionCategory.trabalho: return AppColors.categoryTrabalho;
      case InstitutionCategory.violenciaDomestica: return AppColors.categoryViolencia;
      case InstitutionCategory.consumidor: return AppColors.categoryConsumidor;
      case InstitutionCategory.moradia: return AppColors.categoryMoradia;
      case InstitutionCategory.documentos: return AppColors.categoryDocumentos;
      case InstitutionCategory.direitosMulher: return AppColors.categoryMulher;
      case InstitutionCategory.aposentadoria: return AppColors.categoryAposentadoria;
      case InstitutionCategory.outros: return AppColors.categoryOutros;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        scale: _hover ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 180),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          elevation: _hover ? 6 : 3,
          shadowColor: _color.withValues(alpha: 0.35),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: widget.onTap,
            splashColor: _color.withValues(alpha: 0.1),
            highlightColor: _color.withValues(alpha: 0.05),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _hover ? _color.withValues(alpha: 0.5) : _color.withValues(alpha: 0.18),
                  width: _hover ? 2 : 1.5,
                ),
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    _color.withValues(alpha: 0.04),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _color.withValues(alpha: 0.18),
                          _color.withValues(alpha: 0.10),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _color.withValues(alpha: 0.18),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(_icon, color: _color, size: 30),
                  ),
                  const SizedBox(height: 10),
                  Flexible(
                    child: Text(
                      widget.category.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onBackground,
                        height: 1.2,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
