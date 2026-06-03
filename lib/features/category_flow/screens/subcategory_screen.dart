import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../models/institution.dart';
import '../../../models/subcategory.dart';
import '../../../providers/flow_provider.dart';
import '../../../shared/widgets/geo_app_bar.dart';

class SubcategoryScreen extends ConsumerWidget {
  const SubcategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = ref.watch(flowProvider);
    final category = flow.category;
    if (category == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go(AppRoutes.home));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final subs = SubcategoryRegistry.get(category);
    // Se não tem sub-categorias, vai direto pro fluxo
    if (subs.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => context.go(AppRoutes.flow));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: GeoAppBar(title: category.label),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, c) {
          final isWide = c.maxWidth > 600;
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? c.maxWidth * 0.18 : 20,
              vertical: 22,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _questionFor(category),
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        height: 1.25,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Toque na opção que mais se parece com o seu caso.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 18),
                ...subs.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _SubOption(
                        sub: s,
                        onTap: () {
                          ref.read(flowProvider.notifier).setSubcategory(s.id);
                          context.push(AppRoutes.flow);
                        },
                      ),
                    )),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lightbulb_outline_rounded,
                          color: AppColors.secondary, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Em dúvida? Escolha "Outro". Vamos te orientar mesmo assim.',
                          style: TextStyle(fontSize: 13, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  String _questionFor(InstitutionCategory cat) {
    switch (cat) {
      case InstitutionCategory.familia: return 'Sobre o que você precisa?';
      case InstitutionCategory.trabalho: return 'O que aconteceu no seu trabalho?';
      case InstitutionCategory.aposentadoria: return 'Que tipo de benefício?';
      case InstitutionCategory.consumidor: return 'Qual o problema?';
      case InstitutionCategory.moradia: return 'Qual sua situação?';
      case InstitutionCategory.documentos: return 'Qual documento?';
      case InstitutionCategory.direitosMulher: return 'Qual sua situação?';
      case InstitutionCategory.saude: return 'Do que você precisa?';
      case InstitutionCategory.denuncias: return 'O que você quer denunciar?';
      case InstitutionCategory.violenciaDomestica:
      case InstitutionCategory.outros: return 'Vamos te orientar';
    }
  }
}

class _SubOption extends StatelessWidget {
  final Subcategory sub;
  final VoidCallback onTap;
  const _SubOption({required this.sub, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(sub.icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sub.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    if (sub.quickTip != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.lightbulb_rounded,
                              size: 12, color: AppColors.warning),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              sub.quickTip!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: AppColors.primary, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
