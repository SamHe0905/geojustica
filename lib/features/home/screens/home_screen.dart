import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../models/institution.dart';
import '../../../providers/flow_provider.dart';
import '../../../providers/institution_provider.dart';
import '../../../shared/widgets/geo_app_bar.dart';
import '../../../shared/widgets/sos_button.dart';
import '../../../shared/widgets/accessibility_bar.dart';
import '../../../shared/widgets/staggered_entrance.dart';
import '../../../shared/widgets/geo_icon.dart';
import '../widgets/category_button.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allInst = ref.watch(allInstitutionsProvider);

    return Scaffold(
      appBar: GeoAppBar(showBack: false, actions: [
        IconButton(
          icon: const GeoIcon('history', color: Colors.white, size: 22),
          tooltip: 'Histórico',
          onPressed: () => context.push(AppRoutes.history),
        ),
        IconButton(
          icon: const GeoIcon('map', color: Colors.white, size: 22),
          tooltip: 'Mapa geral',
          onPressed: () => context.push(AppRoutes.mapAll),
        ),
      ]),
      floatingActionButton: const SosButton(),
      body: SafeArea(
        child: Column(children: [
          const AccessibilityBar(),
          Expanded(child: LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            final horizontalPadding = isWide ? constraints.maxWidth * 0.12 : 20.0;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
              child: StaggeredEntrance(
                children: [
                  _buildHero(context, allInst.maybeWhen(data: (list) => list.length, orElse: () => 0)),
                  const SizedBox(height: 20),
                  _buildSearchBar(context),
                  const SizedBox(height: 32),
                  _buildSectionTitle(context),
                  const SizedBox(height: 16),
                  _buildCategoryGrid(context, ref, isWide),
                  const SizedBox(height: 24),
                  _buildLawyersCard(context),
                  const SizedBox(height: 22),
                  _buildHelpTip(context),
                  const SizedBox(height: 16),
                  _buildFooter(context),
                ],
              ),
            );
          })),
        ]),
      ),
    );
  }

  Widget _buildHero(BuildContext context, int institutionCount) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.forest,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Assinatura geo: vias radiais + anel de Campo Grande (sutil).
          Positioned.fill(
            child: CustomPaint(painter: _GeoSignaturePainter()),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Acesso à justiça,\nperto de você',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white, height: 1.12),
                ),
                const SizedBox(height: 10),
                Text(
                  'Orientação gratuita para resolver seu problema, passo a passo.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 9,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _metaItem('pin', 'Campo Grande/MS'),
                    if (institutionCount > 0) ...[
                      Container(width: 3, height: 3, decoration: const BoxDecoration(color: Colors.white54, shape: BoxShape.circle)),
                      Text(
                        '$institutionCount locais cadastrados',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12.5, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaItem(String iconName, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GeoIcon(iconName, color: Colors.white.withValues(alpha: 0.85), size: 15),
        const SizedBox(width: 5),
        Text(text, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12.5, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.search),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider, width: 1.5),
          boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 6, offset: Offset(0, 1))],
        ),
        child: Row(
          children: [
            const GeoIcon('search', color: AppColors.primary, size: 22),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                'Descreva sua situação…',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15.5, fontWeight: FontWeight.w500),
              ),
            ),
            const GeoIcon('mic', color: AppColors.textMuted, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.homeQuestion,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 3),
        Text(
          'Toque numa área para começar.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildCategoryGrid(BuildContext context, WidgetRef ref, bool isWide) {
    return GridView.count(
      crossAxisCount: isWide ? 4 : 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.95,
      children: InstitutionCategory.values.map((cat) {
        return CategoryButton(
          category: cat,
          onTap: () {
            ref.read(flowProvider.notifier).reset();
            ref.read(flowProvider.notifier).setCategory(cat);
            if (cat == InstitutionCategory.violenciaDomestica) {
              context.push(AppRoutes.safetyCheck);
            } else {
              context.push(AppRoutes.subcategory);
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildLawyersCard(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push(AppRoutes.lawyers),
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: AppColors.forestTint,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: AppColors.forest, borderRadius: BorderRadius.circular(11)),
                child: const Center(child: GeoIcon('handshake', color: Colors.white, size: 23)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Advogados parceiros', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15.5)),
                    const SizedBox(height: 2),
                    Text('Atendimento gratuito, social ou facilitado.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                  ],
                ),
              ),
              const GeoIcon('caret', color: AppColors.primary, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpTip(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 1),
          child: GeoIcon('info', color: AppColors.textSecondary, size: 20),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Não sabe por onde começar?',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: AppColors.ink)),
              const SizedBox(height: 1),
              Text('Toque na busca e descreva seu problema com suas palavras.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.35)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 3,
              decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(3)),
            ),
            const SizedBox(height: 12),
            Text('Serviço público e gratuito',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11.5, fontWeight: FontWeight.w600, letterSpacing: 0.4)),
          ],
        ),
      ),
    );
  }
}

/// Vias radiais + anel — evoca o traçado de Campo Grande sem fingir o mapa
/// exato. Desenhado claro sobre o verde, em baixa opacidade.
class _GeoSignaturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width - 34, size.height * 0.42);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..color = Colors.white;

    for (final r in [26.0, 48.0, 72.0]) {
      stroke.color = Colors.white.withValues(alpha: r == 26 ? 0.13 : (r == 48 ? 0.09 : 0.05));
      canvas.drawCircle(center, r, stroke);
    }

    stroke.color = Colors.white.withValues(alpha: 0.10);
    for (final a in [-1.4, -0.5, 0.4, 1.2, 2.3]) {
      final end = center + Offset(90 * math.cos(a), 90 * math.sin(a));
      canvas.drawLine(center, end, stroke);
    }

    final dot = Paint()..color = Colors.white.withValues(alpha: 0.16);
    for (final o in [const Offset(-6, -26), const Offset(26, 22), const Offset(-28, 16)]) {
      canvas.drawCircle(center + o, 3.0, dot);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
