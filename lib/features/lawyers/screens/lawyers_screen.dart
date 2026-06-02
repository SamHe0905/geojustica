import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/institution.dart';
import '../../../models/lawyer.dart';
import '../../../providers/lawyer_provider.dart';
import '../../../shared/widgets/geo_app_bar.dart';

class LawyersScreen extends ConsumerWidget {
  const LawyersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lawyers = ref.watch(filteredLawyersProvider);
    final filter = ref.watch(lawyerFilterProvider);

    return Scaffold(
      appBar: GeoAppBar(
        title: 'Advogados Parceiros',
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded, color: Colors.white),
            tooltip: 'Sou advogado e quero me cadastrar',
            onPressed: () => context.push('/advogados/cadastro'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, lawyers.length),
            _buildFilters(context, ref, filter),
            Expanded(
              child: lawyers.isEmpty
                  ? _buildEmpty(context, ref)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: lawyers.length,
                      itemBuilder: (_, i) => _LawyerCard(lawyer: lawyers[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int count) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.secondary, AppColors.secondaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.handshake_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Advogados que ajudam',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900)),
                Text(
                  '$count profissionais com atendimento social, gratuito ou facilitado',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context, WidgetRef ref, LawyerFilter filter) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          FilterChip(
            label: const Text('Atendimento gratuito'),
            avatar: const Text('🆓'),
            selected: filter.onlyFree,
            onSelected: (v) => ref.read(lawyerFilterProvider.notifier).state =
                filter.copyWith(onlyFree: v),
            backgroundColor: Colors.white,
            selectedColor: AppColors.success.withOpacity(0.2),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Verificados'),
            avatar: const Icon(Icons.verified_rounded,
                size: 16, color: AppColors.secondary),
            selected: filter.onlyVerified,
            onSelected: (v) => ref.read(lawyerFilterProvider.notifier).state =
                filter.copyWith(onlyVerified: v),
            backgroundColor: Colors.white,
            selectedColor: AppColors.secondary.withOpacity(0.2),
          ),
          const SizedBox(width: 8),
          for (final cat in InstitutionCategory.values) ...[
            FilterChip(
              label: Text(cat.label),
              selected: filter.category == cat,
              onSelected: (v) {
                ref.read(lawyerFilterProvider.notifier).state =
                    filter.copyWith(category: v ? cat : null);
              },
              backgroundColor: Colors.white,
              selectedColor: AppColors.primary.withOpacity(0.2),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded, size: 56, color: AppColors.textMuted),
          const SizedBox(height: 12),
          const Text('Nenhum advogado encontrado com esses filtros',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => ref.read(lawyerFilterProvider.notifier).state =
                const LawyerFilter(),
            child: const Text('Limpar filtros'),
          ),
        ],
      ),
    );
  }
}

class _LawyerCard extends StatelessWidget {
  final Lawyer lawyer;
  const _LawyerCard({required this.lawyer});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/advogados/${lawyer.id}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primary.withOpacity(0.15),
                    child: Text(
                      lawyer.initials,
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                lawyer.name,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (lawyer.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.verified_rounded,
                                  color: AppColors.secondary, size: 16),
                            ],
                          ],
                        ),
                        Text(lawyer.oab,
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                color: AppColors.accent, size: 16),
                            const SizedBox(width: 2),
                            Text(
                              lawyer.rating.toStringAsFixed(1),
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                            Text(' (${lawyer.ratingCount})',
                                style: const TextStyle(
                                    color: AppColors.textMuted, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (lawyer.modalities.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: lawyer.modalities.map((m) {
                    final isFree = m == LawyerModality.proBono;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (isFree ? AppColors.success : AppColors.primary)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${m.icon} ${m.label}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isFree ? AppColors.success : AppColors.primary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${lawyer.neighborhood} • ${lawyer.specialties.map((s) => s.label).join(", ")}',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
