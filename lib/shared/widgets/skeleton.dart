import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';

/// Bloco de skeleton com shimmer. Placeholder de carregamento que espelha a
/// forma do conteúdo real — melhor que um spinner no vazio.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const SkeletonBox({super.key, this.width, required this.height, this.radius = 10});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Lista de cards em skeleton, para o carregamento de resultados/mapa.
///
/// Respeita `prefers-reduced-motion`: sem o brilho animado, mostra os blocos
/// estáticos.
class SkeletonList extends StatelessWidget {
  final int items;
  final EdgeInsetsGeometry padding;

  const SkeletonList({
    super.key,
    this.items = 5,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    Widget content = ListView.separated(
      padding: padding,
      itemCount: items,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const _SkeletonCard(),
    );

    if (reduce) return content;

    return Shimmer.fromColors(
      baseColor: const Color(0xFFE7E7E1),
      highlightColor: const Color(0xFFF5F5F0),
      child: content,
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          const SkeletonBox(width: 46, height: 46, radius: 12),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBox(height: 15, radius: 7),
                SizedBox(height: 9),
                SkeletonBox(width: 160, height: 12, radius: 6),
                SizedBox(height: 14),
                SkeletonBox(width: 110, height: 12, radius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
