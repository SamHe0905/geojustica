import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/flow_provider.dart';
import '../../../providers/institution_provider.dart';
import '../../category_flow/widgets/required_docs_banner.dart';
import '../../../services/schedule_service.dart';
import '../../../shared/widgets/geo_app_bar.dart';
import '../../../shared/widgets/geo_icon.dart';
import '../../../shared/widgets/geo_state_view.dart';
import '../../../shared/widgets/location_picker.dart';
import '../../../shared/widgets/skeleton.dart';
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
            icon: const GeoIcon('map', color: Colors.white, size: 22),
            tooltip: 'Ver no mapa',
            onPressed: () => context.push(AppRoutes.map),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          final listPadding = EdgeInsets.symmetric(
            horizontal: isWide ? constraints.maxWidth * 0.1 : 16,
            vertical: 8,
          );
          return institutionsAsync.when(
            loading: () => SkeletonList(padding: listPadding),
            error: (e, _) => GeoStateView.error(
              onRetry: () => ref.invalidate(institutionsByFlowProvider(flow)),
            ),
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
                  const RequiredDocsBanner(),
                  if (flow.locationLabel != null)
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        isWide ? constraints.maxWidth * 0.1 : 16,
                        10,
                        isWide ? constraints.maxWidth * 0.1 : 16,
                        0,
                      ),
                      child: Row(
                        children: [
                          const GeoIcon('pin', color: AppColors.primary, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Perto de: ${flow.locationLabel}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => showLocationPicker(context, ref),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              minimumSize: const Size(0, 32),
                            ),
                            child: const Text('Trocar'),
                          ),
                        ],
                      ),
                    ),
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
    return GeoStateView.empty(
      title: 'Nada encontrado por aqui',
      message: 'Não achamos instituições para essa busca. Tente descrever de outro jeito ou veja todas as áreas.',
      actionLabel: 'Ver todas as áreas',
      onAction: () => context.go(AppRoutes.home),
    );
  }
}
