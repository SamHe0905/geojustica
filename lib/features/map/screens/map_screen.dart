import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/institution.dart';
import '../../../providers/flow_provider.dart';
import '../../../providers/institution_provider.dart';
import '../../../services/location_service.dart';
import '../../../shared/widgets/geo_app_bar.dart';

class MapScreen extends ConsumerStatefulWidget {
  final bool showAll;
  const MapScreen({super.key, this.showAll = false});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _mapController = MapController();
  InstitutionCategory? _filterCategory;

  Color _categoryColor(InstitutionCategory cat) {
    switch (cat) {
      case InstitutionCategory.familia: return AppColors.categoryFamilia;
      case InstitutionCategory.trabalho: return AppColors.categoryTrabalho;
      case InstitutionCategory.violenciaDomestica: return AppColors.categoryViolencia;
      case InstitutionCategory.consumidor: return AppColors.categoryConsumidor;
      case InstitutionCategory.moradia: return AppColors.categoryMoradia;
      case InstitutionCategory.documentos: return AppColors.categoryDocumentos;
      case InstitutionCategory.direitosMulher: return AppColors.categoryMulher;
      case InstitutionCategory.aposentadoria: return AppColors.categoryAposentadoria;
      case InstitutionCategory.saude: return AppColors.categorySaude;
      case InstitutionCategory.denuncias: return AppColors.categoryDenuncias;
      case InstitutionCategory.outros: return AppColors.categoryOutros;
    }
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(flowProvider);
    final allAsync = ref.watch(allInstitutionsProvider);
    final flowAsync = ref.watch(institutionsByFlowProvider(flow));

    final center = flow.hasLocation
        ? LatLng(flow.userLatitude!, flow.userLongitude!)
        : LocationService.campoGrandeCenter;

    return Scaffold(
      appBar: GeoAppBar(
        title: widget.showAll ? 'Mapa Geral' : 'Mapa',
        actions: [
          if (widget.showAll)
            IconButton(
              icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
              tooltip: 'Filtrar categoria',
              onPressed: () => _showCategoryFilter(context),
            ),
        ],
      ),
      body: allAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (allInstitutions) {
          final flowInstitutions = widget.showAll
              ? null
              : flowAsync.valueOrNull;

          final institutions = widget.showAll
              ? (_filterCategory == null
                  ? allInstitutions
                  : allInstitutions.where((i) => i.category == _filterCategory).toList())
              : (flowInstitutions ?? []);

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: widget.showAll ? 12.0 : 13.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'br.ms.geojustica',
                  ),
                  if (flow.hasLocation)
                    MarkerLayer(markers: [
                      Marker(
                        point: center,
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.my_location_rounded,
                            color: AppColors.secondary, size: 36),
                      ),
                    ]),
                  MarkerLayer(
                    markers: institutions.map((inst) {
                      final color = _categoryColor(inst.category);
                      return Marker(
                        point: inst.latLng,
                        width: 44,
                        height: 44,
                        child: GestureDetector(
                          onTap: () => _showInstitutionCard(context, inst),
                          child: Tooltip(
                            message: inst.name,
                            child: Container(
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                      color: color.withValues(alpha: 0.4), blurRadius: 6),
                                ],
                              ),
                              child: const Icon(Icons.balance,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              // Legenda de categorias (mapa geral)
              if (widget.showAll)
                Positioned(
                  top: 12,
                  left: 12,
                  child: _buildLegend(context),
                ),

              // Contador de pins
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                  ),
                  child: Text(
                    '${institutions.length} locais',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ),
              ),

              // Botões de zoom
              Positioned(
                bottom: 20,
                right: 16,
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'zoom_in',
                      onPressed: () => _mapController.move(
                          _mapController.camera.center,
                          _mapController.camera.zoom + 1),
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.add, color: AppColors.primary),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: 'zoom_out',
                      onPressed: () => _mapController.move(
                          _mapController.camera.center,
                          _mapController.camera.zoom - 1),
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.remove, color: AppColors.primary),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: 'center',
                      onPressed: () => _mapController.move(center, 12.0),
                      backgroundColor: AppColors.primary,
                      child: const Icon(Icons.my_location_rounded,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    final cats = [
      InstitutionCategory.familia,
      InstitutionCategory.trabalho,
      InstitutionCategory.violenciaDomestica,
      InstitutionCategory.consumidor,
      InstitutionCategory.moradia,
      InstitutionCategory.direitosMulher,
      InstitutionCategory.aposentadoria,
      InstitutionCategory.outros,
    ];
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.93),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: cats.map((cat) {
          final selected = _filterCategory == cat;
          return GestureDetector(
            onTap: () => setState(() =>
                _filterCategory = selected ? null : cat),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Container(
                    width: 14, height: 14,
                    decoration: BoxDecoration(
                      color: _categoryColor(cat),
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(color: Colors.black, width: 2)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                      color: selected ? AppColors.onBackground : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showInstitutionCard(BuildContext context, Institution inst) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 12, height: 12,
                decoration: BoxDecoration(
                    color: _categoryColor(inst.category), shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(inst.category.label,
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 6),
            Text(inst.name,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary)),
            const SizedBox(height: 4),
            Text('${inst.address} – ${inst.neighborhood}',
                style: const TextStyle(color: AppColors.textSecondary)),
            if (inst.schedule != null) ...[
              const SizedBox(height: 4),
              Text(inst.schedule!,
                  style: const TextStyle(color: AppColors.textSecondary)),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.push('/instituicao/${inst.id}');
              },
              child: const Text('Ver detalhes completos'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Filtrar por categoria',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ),
          ListTile(
            leading: const Icon(Icons.all_inclusive_rounded),
            title: const Text('Todas as categorias'),
            selected: _filterCategory == null,
            onTap: () {
              setState(() => _filterCategory = null);
              Navigator.pop(context);
            },
          ),
          ...InstitutionCategory.values.map((cat) => ListTile(
                leading: CircleAvatar(
                    backgroundColor: _categoryColor(cat), radius: 10),
                title: Text(cat.label),
                selected: _filterCategory == cat,
                onTap: () {
                  setState(() => _filterCategory = cat);
                  Navigator.pop(context);
                },
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
