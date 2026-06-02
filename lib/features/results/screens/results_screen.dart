import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/flow_provider.dart';
import '../../../providers/institution_provider.dart';
import '../../../services/schedule_service.dart';
import '../../../shared/widgets/geo_app_bar.dart';
import '../widgets/institution_card.dart';

class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({super.key});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  bool _onlyOpenNow = false;
  final _scheduleService = ScheduleService();

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(flowProvider);
    final institutionsAsync = ref.watch(institutionsByFlowProvider(flow));

    return Scaffold(
      appBar: GeoAppBar(
        title: flow.category?.label ?? AppStrings.resultsTitle,
        actions: [
          IconButton(
            icon: const Icon(Icons.map_rounded, color: Colors.white),
            tooltip: 'Ver no mapa',
            onPressed: () => context.push(AppRoutes.map),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return institutionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erro: $e')),
            data: (allInstitutions) {
              final institutions = _onlyOpenNow
                  ? allInstitutions
                      .where((i) => _scheduleService.isOpenNow(i.schedule))
                      .toList()
                  : allInstitutions;

              if (allInstitutions.isEmpty) return _buildEmpty(context);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? constraints.maxWidth * 0.1 : 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${institutions.length} de ${allInstitutions.length}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        FilterChip(
                          label: const Text('Abertos agora'),
                          avatar: Icon(
                            _onlyOpenNow
                                ? Icons.check_circle_rounded
                                : Icons.access_time_rounded,
                            size: 16,
                            color: _onlyOpenNow ? Colors.white : AppColors.primary,
                          ),
                          selected: _onlyOpenNow,
                          onSelected: (v) => setState(() => _onlyOpenNow = v),
                          backgroundColor: Colors.white,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: _onlyOpenNow ? Colors.white : AppColors.onBackground,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (institutions.isEmpty)
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.access_time_filled_rounded,
                                  size: 48, color: AppColors.textMuted),
                              const SizedBox(height: 12),
                              const Text(
                                'Nenhuma instituição aberta agora.',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () =>
                                    setState(() => _onlyOpenNow = false),
                                child: const Text('Ver todas'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: isWide ? constraints.maxWidth * 0.1 : 16,
                        ),
                        itemCount: institutions.length,
                        itemBuilder: (context, i) =>
                            InstitutionCard(institution: institutions[i]),
                      ),
                    ),
                ],
              );
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'home',
        onPressed: () => context.go(AppRoutes.home),
        icon: const Icon(Icons.home_rounded),
        label: const Text('Início'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded,
              size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          const Text(AppStrings.noResults,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.home),
            child: const Text('Voltar ao início'),
          ),
        ],
      ),
    );
  }
}
