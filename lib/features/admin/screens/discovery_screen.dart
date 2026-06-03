import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/institution.dart';
import '../../../providers/institution_provider.dart';
import '../../../services/osm_discovery_service.dart';
import '../../../shared/widgets/geo_app_bar.dart';

class DiscoveryScreen extends ConsumerStatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  ConsumerState<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends ConsumerState<DiscoveryScreen> {
  final _service = OsmDiscoveryService();
  List<DiscoveredOrg> _results = [];
  List<DiscoveredOrg> _newOnes = [];
  List<DiscoveredOrg> _duplicates = [];
  bool _searching = false;
  bool _searched = false;
  String? _error;
  InstitutionCategory? _filterCategory;

  Future<void> _discover() async {
    setState(() {
      _searching = true;
      _error = null;
      _results = [];
      _newOnes = [];
      _duplicates = [];
    });
    try {
      final found = await _service.discoverInCampoGrande();
      final existing = await ref.read(allInstitutionsProvider.future);
      final existingNames =
          existing.map((i) => _normalize(i.name)).toSet();

      final news = <DiscoveredOrg>[];
      final dups = <DiscoveredOrg>[];
      for (final o in found) {
        if (existingNames.contains(_normalize(o.name))) {
          dups.add(o);
        } else {
          news.add(o);
        }
      }
      // Marca duplicatas como não-selecionadas por padrão
      for (final d in dups) {
        d.selected = false;
      }

      setState(() {
        _searching = false;
        _searched = true;
        _results = found;
        _newOnes = news;
        _duplicates = dups;
      });
    } catch (e) {
      setState(() {
        _searching = false;
        _error = 'Não foi possível buscar agora: $e';
      });
    }
  }

  String _normalize(String s) {
    return s
        .toLowerCase()
        .replaceAll(RegExp(r'[áàâãä]'), 'a')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[íìîï]'), 'i')
        .replaceAll(RegExp(r'[óòôõö]'), 'o')
        .replaceAll(RegExp(r'[úùûü]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c')
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  List<DiscoveredOrg> get _visible {
    if (_filterCategory == null) return _newOnes;
    return _newOnes.where((o) => o.category == _filterCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GeoAppBar(title: 'Descobrir órgãos'),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (_error != null) _buildError(),
            if (_searched && _results.isNotEmpty) _buildStats(),
            if (_searched && _newOnes.isNotEmpty) _buildFilters(),
            Expanded(child: _buildBody()),
            if (_searched && _newOnes.isNotEmpty) _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.travel_explore_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Buscar órgãos públicos',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900)),
                SizedBox(height: 2),
                Text(
                  'Apenas dentro da fronteira de Campo Grande/MS. Não pega de outros municípios.',
                  style: TextStyle(color: Colors.white, fontSize: 12, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(_error!, style: const TextStyle(color: AppColors.error))),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: _statBox('${_results.length}', 'Total encontrados',
                AppColors.primary, Icons.public_rounded),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _statBox('${_newOnes.length}', 'Novos',
                AppColors.success, Icons.fiber_new_rounded),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _statBox('${_duplicates.length}', 'Já cadastrados',
                AppColors.textMuted, Icons.check_circle_rounded),
          ),
        ],
      ),
    );
  }

  Widget _statBox(String value, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w900, color: color)),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          FilterChip(
            label: const Text('Todos'),
            selected: _filterCategory == null,
            onSelected: (_) => setState(() => _filterCategory = null),
          ),
          const SizedBox(width: 6),
          ...InstitutionCategory.values
              .where((c) => _newOnes.any((n) => n.category == c))
              .map((c) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      label: Text(c.label),
                      selected: _filterCategory == c,
                      onSelected: (_) => setState(() => _filterCategory = c),
                    ),
                  )),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_searching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 18),
            Text('Buscando órgãos no OpenStreetMap...'),
            SizedBox(height: 6),
            Text('Pode demorar até 30 segundos.',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      );
    }

    if (!_searched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.travel_explore_rounded,
                size: 64, color: AppColors.primary),
            const SizedBox(height: 18),
            const Text('Buscar órgãos automaticamente',
                style:
                    TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 4),
            const Text(
              'Consulta o OpenStreetMap em Campo Grande/MS\ne classifica em categorias.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _discover,
              icon: const Icon(Icons.search_rounded),
              label: const Text('Iniciar busca'),
            ),
          ],
        ),
      );
    }

    if (_newOnes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 48),
              const SizedBox(height: 14),
              const Text('Tudo em dia!',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text(
                'Não há órgãos novos para importar. A base atual já cobre o que está no OpenStreetMap.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _discover,
                child: const Text('Buscar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    final list = _visible;
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (context, i) {
        final o = list[i];
        return Card(
          margin: EdgeInsets.zero,
          child: CheckboxListTile(
            value: o.selected,
            onChanged: (v) => setState(() => o.selected = v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(o.name,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${o.address} • ${o.neighborhood}',
                    style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(o.category.label,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary)),
                    ),
                    const SizedBox(width: 6),
                    Text(o.tagSource,
                        style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                            fontFamily: 'monospace')),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    final selectedCount = _newOnes.where((o) => o.selected).length;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text('$selectedCount selecionados',
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                for (final o in _newOnes) {
                  o.selected = true;
                }
              });
            },
            child: const Text('Selecionar todos'),
          ),
          const SizedBox(width: 6),
          ElevatedButton.icon(
            onPressed: selectedCount == 0 ? null : _confirmImport,
            icon: const Icon(Icons.cloud_upload_rounded),
            label: Text('Importar ($selectedCount)'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmImport() async {
    final selected = _newOnes.where((o) => o.selected).toList();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.check_circle_rounded,
            color: AppColors.success, size: 48),
        title: Text('Importar ${selected.length} órgãos?'),
        content: const Text(
          'Os registros serão preparados para envio ao Supabase. '
          'A persistência em massa será implementada na próxima atualização.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${selected.length} órgãos preparados.')),
              );
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}
