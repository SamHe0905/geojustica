import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../models/institution.dart';
import '../../../models/report.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/institution_provider.dart';
import '../../../providers/report_provider.dart';
import '../../../providers/team_provider.dart';
import '../../../services/excel_import_service.dart';
import '../../../shared/widgets/geo_app_bar.dart';
import '../../../shared/widgets/skeleton.dart';
import '../widgets/team_tab.dart';
import 'institution_edit_screen.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

enum DuplicateAction { skip, update, addAll }

class _AdminScreenState extends ConsumerState<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final bool _isOwner;
  bool _importing = false;
  String? _importStatus;
  List<Institution>? _previewData;
  List<Institution> _duplicates = [];
  List<Institution> _newOnes = [];
  DuplicateAction _duplicateAction = DuplicateAction.skip;

  // Seleção manual na aba Instituições (para excluir duplicados na mão).
  bool _selectionMode = false;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    // A aba "Equipe" só existe para o dono. O AdminGuard remonta esta tela a
    // cada login, então basta ler o papel uma vez.
    _isOwner = ref.read(adminAuthProvider).isOwner;
    _tabController = TabController(length: _isOwner ? 4 : 3, vsync: this);
    // Rebuild ao trocar de aba, para o botão flutuante "Adicionar órgão"
    // aparecer só na aba Instituições.
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Auth já é verificada pelo AdminGuard, então aqui só renderiza
    final reports = ref.watch(reportListProvider);
    final member = ref.watch(adminAuthProvider).member;

    return Scaffold(
      appBar: GeoAppBar(
        title: 'Painel Administrativo',
        actions: [
          if (member != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Tooltip(
                  message: '${member.name} (${member.role.label})',
                  child: Chip(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: Colors.white.withValues(alpha: 0.18),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                    avatar: Icon(
                      member.isOwner
                          ? Icons.shield_rounded
                          : Icons.person_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: Text(
                      '@${member.username}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Atualizar',
            onPressed: () {
              ref.invalidate(allInstitutionsProvider);
              ref.invalidate(adminInstitutionsProvider);
              ref.invalidate(teamListProvider);
              ref.read(reportListProvider.notifier).refresh();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: 'Sair',
            onPressed: () async {
              await ref.read(adminAuthProvider.notifier).logout();
              if (mounted) context.go(AppRoutes.home);
            },
          ),
        ],
      ),
      floatingActionButton: (_tabController.index == 1 && !_selectionMode)
          ? FloatingActionButton.extended(
              onPressed: _createInstitution,
              icon: const Icon(Icons.add_location_alt_rounded),
              label: const Text('Adicionar órgão'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            )
          : null,
      body: Column(
        children: [
          Container(
            color: AppColors.primary,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              indicatorColor: Colors.white,
              isScrollable: true,
              tabs: [
                const Tab(
                  icon: Icon(Icons.upload_file_rounded),
                  text: 'Importar',
                ),
                const Tab(
                  icon: Icon(Icons.list_alt_rounded),
                  text: 'Instituições',
                ),
                Tab(
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.report_problem_rounded),
                      if (reports.isNotEmpty)
                        Positioned(
                          top: -4,
                          right: -8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${reports.length}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  text: 'Denúncias',
                ),
                if (_isOwner)
                  const Tab(icon: Icon(Icons.groups_rounded), text: 'Equipe'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildImportTab(),
                _buildInstitutionsTab(),
                _buildReportsTab(reports),
                if (_isOwner) const TeamTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============== ABA: IMPORTAR ==============
  Widget _buildImportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInstructionsCard(),
          const SizedBox(height: 20),
          if (_previewData == null)
            ElevatedButton.icon(
              onPressed: _importing ? null : _pickAndImport,
              icon: _importing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.upload_file_rounded),
              label: Text(
                _importing ? 'Lendo arquivo...' : 'Selecionar planilha Excel',
              ),
            ),
          if (_importStatus != null && _previewData == null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _importStatus!,
                style: const TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          if (_previewData != null) _buildPreview(),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.lightbulb_rounded,
                color: AppColors.secondary,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Como importar planilhas',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _step(
            '1',
            'A planilha precisa ter as colunas obrigatórias (nome, endereço, bairro, categoria, latitude, longitude).',
          ),
          _step('2', 'Os nomes das colunas devem estar na primeira linha.'),
          _step(
            '3',
            'Os múltiplos serviços/categorias devem ser separados por ponto e vírgula (;).',
          ),
          _step(
            '4',
            'Após selecionar o arquivo, você poderá decidir o que fazer com instituições que já existem (duplicatas).',
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            'Colunas esperadas:',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.divider),
            ),
            child: const Text(
              'nome, endereco, bairro, telefone, whatsapp,\n'
              'categoria, servicos, horario, observacoes,\n'
              'esfera, latitude, longitude,\n'
              'atende_gratuito, ativo',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _step(String n, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                n,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    final hasDups = _duplicates.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _statBox(
                '${_previewData!.length}',
                'Total lidos',
                AppColors.primary,
                Icons.list_alt_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statBox(
                '${_newOnes.length}',
                'Novos',
                AppColors.success,
                Icons.fiber_new_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statBox(
                '${_duplicates.length}',
                'Já existem',
                hasDups ? AppColors.warning : AppColors.textMuted,
                Icons.content_copy_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (hasDups) ...[
          const Text(
            'Como tratar as duplicatas?',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(height: 8),
          _duplicateOption(
            DuplicateAction.skip,
            'Ignorar duplicatas',
            'Só importa as novas. Recomendado.',
            Icons.skip_next_rounded,
            AppColors.success,
          ),
          _duplicateOption(
            DuplicateAction.update,
            'Atualizar existentes',
            'Sobrescreve os dados das duplicatas com os da planilha.',
            Icons.update_rounded,
            AppColors.warning,
          ),
          _duplicateOption(
            DuplicateAction.addAll,
            'Importar tudo mesmo assim',
            'Vai criar registros repetidos. Use com cuidado.',
            Icons.add_circle_outline_rounded,
            AppColors.error,
          ),
          const SizedBox(height: 14),
          const Text(
            'Duplicatas detectadas:',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
          const SizedBox(height: 6),
          ..._duplicates
              .take(3)
              .map(
                (d) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    '• ${d.name}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
          if (_duplicates.length > 3)
            Text(
              '… e mais ${_duplicates.length - 3}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          const SizedBox(height: 14),
        ],
        if (_newOnes.isNotEmpty) ...[
          const Text(
            'Novos que serão adicionados:',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
          const SizedBox(height: 6),
          ..._newOnes
              .take(3)
              .map(
                (d) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    '• ${d.name}',
                    style: const TextStyle(
                      color: AppColors.success,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
          if (_newOnes.length > 3)
            Text(
              '… e mais ${_newOnes.length - 3}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          const SizedBox(height: 16),
        ],
        ElevatedButton.icon(
          onPressed: _importing ? null : _confirmImport,
          icon: const Icon(Icons.cloud_upload_rounded),
          label: Text(_importing ? 'Salvando...' : 'Confirmar importação'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () {
            setState(() {
              _previewData = null;
              _duplicates = [];
              _newOnes = [];
              _importStatus = null;
            });
          },
          child: const Text('Cancelar'),
        ),
      ],
    );
  }

  Widget _duplicateOption(
    DuplicateAction action,
    String label,
    String desc,
    IconData icon,
    Color color,
  ) {
    final selected = _duplicateAction == action;
    return Material(
      color: selected ? color.withValues(alpha: 0.1) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _duplicateAction = action),
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color : AppColors.divider,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      desc,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected) Icon(Icons.check_circle_rounded, color: color),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statBox(String value, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ============== ABA: INSTITUIÇÕES ==============
  Widget _buildInstitutionsTab() {
    final institutionsAsync = ref.watch(adminInstitutionsProvider);
    return institutionsAsync.when(
      loading: () => const SkeletonList(items: 6),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                color: AppColors.error,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                '$e',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.error),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => ref.invalidate(adminInstitutionsProvider),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Tentar de novo'),
              ),
            ],
          ),
        ),
      ),
      data: (institutions) {
        final inactive = institutions.where((i) => !i.isActive).length;
        // Nomes normalizados repetidos = possíveis duplicados (só um aviso
        // visual; a exclusão é sempre manual).
        final nameCounts = <String, int>{};
        for (final inst in institutions) {
          final key = _normalize(inst.name);
          nameCounts[key] = (nameCounts[key] ?? 0) + 1;
        }
        final dupCount = nameCounts.values
            .where((c) => c > 1)
            .fold<int>(0, (a, b) => a + b);
        // Seleções que não existem mais (ex.: após excluir) são descartadas.
        _selectedIds.retainWhere(
          (id) => institutions.any((inst) => inst.id == id),
        );

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: _statBox(
                      '${institutions.length}',
                      'Órgãos cadastrados',
                      AppColors.primary,
                      Icons.balance_rounded,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _statBox(
                      '$inactive',
                      'Desativados',
                      inactive > 0 ? AppColors.warning : AppColors.textMuted,
                      Icons.visibility_off_rounded,
                    ),
                  ),
                ],
              ),
            ),
            _institutionsActionBar(institutions, dupCount),
            const SizedBox(height: 6),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 88),
                itemCount: institutions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, i) {
                  final inst = institutions[i];
                  final active = inst.isActive;
                  final isDuplicate =
                      (nameCounts[_normalize(inst.name)] ?? 0) > 1;
                  final selected = _selectedIds.contains(inst.id);
                  return Card(
                    color: selected
                        ? AppColors.primary.withValues(alpha: 0.06)
                        : null,
                    child: ListTile(
                      onTap: () => _selectionMode
                          ? _toggleSelection(inst.id)
                          : _editInstitution(inst),
                      onLongPress: () {
                        if (!_selectionMode) {
                          setState(() {
                            _selectionMode = true;
                            _selectedIds.add(inst.id);
                          });
                        }
                      },
                      leading: _selectionMode
                          ? Checkbox(
                              value: selected,
                              onChanged: (_) => _toggleSelection(inst.id),
                            )
                          : Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                    (active
                                            ? AppColors.primary
                                            : AppColors.textMuted)
                                        .withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.balance,
                                color: active
                                    ? AppColors.primary
                                    : AppColors.textMuted,
                                size: 20,
                              ),
                            ),
                      title: Row(
                        children: [
                          Flexible(
                            child: Text(
                              inst.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (isDuplicate) ...[
                            const SizedBox(width: 6),
                            _duplicateBadge(),
                          ],
                        ],
                      ),
                      subtitle: Text(
                        '${inst.category.label} • ${inst.neighborhood}',
                      ),
                      trailing: _selectionMode
                          ? null
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        (active
                                                ? AppColors.success
                                                : AppColors.textMuted)
                                            .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    active ? 'Ativo' : 'Inativo',
                                    style: TextStyle(
                                      color: active
                                          ? AppColors.success
                                          : AppColors.textMuted,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: const Icon(
                                    Icons.more_vert_rounded,
                                    size: 20,
                                    color: AppColors.textMuted,
                                  ),
                                  onSelected: (v) {
                                    if (v == 'edit') _editInstitution(inst);
                                    if (v == 'delete') {
                                      _confirmDeleteInstitutions([inst]);
                                    }
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: ListTile(
                                        leading: Icon(Icons.edit_rounded),
                                        title: Text('Editar'),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: ListTile(
                                        leading: Icon(
                                          Icons.delete_outline_rounded,
                                          color: AppColors.error,
                                        ),
                                        title: Text(
                                          'Excluir',
                                          style: TextStyle(
                                            color: AppColors.error,
                                          ),
                                        ),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ),
                  );
                },
              ),
            ),
            if (_selectionMode) _selectionBottomBar(institutions),
          ],
        );
      },
    );
  }

  /// Barra de ações da aba: adicionar órgão e entrar/sair do modo seleção.
  Widget _institutionsActionBar(List<Institution> institutions, int dupCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: institutions.isEmpty
                  ? null
                  : () => setState(() {
                      _selectionMode = !_selectionMode;
                      _selectedIds.clear();
                    }),
              icon: Icon(
                _selectionMode ? Icons.close_rounded : Icons.checklist_rounded,
                size: 18,
              ),
              label: Text(_selectionMode ? 'Cancelar seleção' : 'Selecionar para excluir'),
            ),
          ),
          if (dupCount > 0 && !_selectionMode) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.content_copy_rounded,
                  size: 14,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '$dupCount órgãos com nome repetido. Use "Selecionar" para '
                    'excluir os duplicados.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Barra fixa embaixo no modo seleção, com a ação de excluir os marcados.
  Widget _selectionBottomBar(List<Institution> institutions) {
    final count = _selectedIds.length;
    return Material(
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Text(
                '$count selecionado${count == 1 ? '' : 's'}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                onPressed: count == 0
                    ? null
                    : () {
                        final toDelete = institutions
                            .where((i) => _selectedIds.contains(i.id))
                            .toList();
                        _confirmDeleteInstitutions(toDelete);
                      },
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: Text('Excluir ($count)'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _duplicateBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'possível duplicado',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.warning,
        ),
      ),
    );
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _createInstitution() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const InstitutionEditScreen()),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Órgão cadastrado.')));
    }
  }

  Future<void> _editInstitution(Institution inst) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => InstitutionEditScreen(institution: inst),
      ),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${inst.name} foi atualizado.')));
    }
  }

  Future<void> _confirmDeleteInstitutions(List<Institution> targets) async {
    if (targets.isEmpty) return;
    final many = targets.length > 1;
    final title = many
        ? 'Excluir ${targets.length} órgãos?'
        : 'Excluir "${targets.first.name}"?';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: const Text(
          'Essa ação é definitiva e remove o(s) órgão(s) do banco de dados. '
          'Para apenas escondê-lo do cidadão, edite e desative em vez de excluir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final repo = ref.read(institutionRepoProvider);
      if (many) {
        await repo.deleteMany(targets.map((i) => i.id).toList());
      } else {
        await repo.deleteOne(targets.first.id);
      }
      ref.invalidate(adminInstitutionsProvider);
      ref.invalidate(allInstitutionsProvider);
      if (!mounted) return;
      setState(() {
        _selectedIds.clear();
        _selectionMode = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            many
                ? '${targets.length} órgãos excluídos.'
                : '"${targets.first.name}" excluído.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Não foi possível excluir: $e')));
    }
  }

  // ============== ABA: DENÚNCIAS ==============
  Widget _buildReportsTab(List<Report> reports) {
    if (reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_rounded,
                color: AppColors.success,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nenhuma denúncia registrada',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tudo certo por aqui!',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(
          children: [
            Expanded(
              child: _statBox(
                '${reports.length}',
                'Total',
                AppColors.primary,
                Icons.flag_rounded,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _statBox(
                '${reports.where((r) => r.status == ReportStatus.pendente).length}',
                'Pendentes',
                AppColors.warning,
                Icons.pending_actions_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...reports.map((r) => _reportCard(r)),
      ],
    );
  }

  Widget _reportCard(Report r) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(r.type.icon, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    r.type.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    r.status.name,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              r.institutionName,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(r.description, maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  r.anonymous ? Icons.visibility_off : Icons.person,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  r.anonymous ? 'Anônimo' : (r.contactName ?? 'Identificado'),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(r.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  // ============== AÇÕES ==============

  Future<void> _pickAndImport() async {
    setState(() {
      _importing = true;
      _importStatus = null;
      _previewData = null;
      _duplicates = [];
      _newOnes = [];
    });
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true,
      );
      if (result == null || result.files.single.bytes == null) {
        setState(() {
          _importing = false;
          _importStatus = 'Nenhum arquivo selecionado.';
        });
        return;
      }
      final imported = ExcelImportService().parseExcel(
        result.files.single.bytes!,
      );

      // Detectar duplicatas pelo nome (normalizado)
      final existing = await ref.read(adminInstitutionsProvider.future);
      final existingNames = existing.map((i) => _normalize(i.name)).toSet();
      final dups = <Institution>[];
      final news = <Institution>[];
      for (final inst in imported) {
        if (existingNames.contains(_normalize(inst.name))) {
          dups.add(inst);
        } else {
          news.add(inst);
        }
      }

      setState(() {
        _importing = false;
        _previewData = imported;
        _duplicates = dups;
        _newOnes = news;
      });
    } catch (e) {
      setState(() {
        _importing = false;
        _importStatus = '✗ Erro ao ler arquivo: $e';
      });
    }
  }

  Future<void> _confirmImport() async {
    if (_previewData == null) return;
    setState(() => _importing = true);
    try {
      final repo = ref.read(institutionRepoProvider);
      final existing = await ref.read(adminInstitutionsProvider.future);
      final idByNormName = {for (final e in existing) _normalize(e.name): e.id};

      int inserted = 0;
      int updated = 0;

      switch (_duplicateAction) {
        case DuplicateAction.skip:
          inserted = await repo.bulkInsert(_newOnes);
        case DuplicateAction.addAll:
          inserted = await repo.bulkInsert(_previewData!);
        case DuplicateAction.update:
          inserted = await repo.bulkInsert(_newOnes);
          for (final dup in _duplicates) {
            final id = idByNormName[_normalize(dup.name)];
            if (id == null) continue;
            await repo.updateOne(id, dup);
            updated++;
          }
      }

      ref.invalidate(allInstitutionsProvider);
      ref.invalidate(adminInstitutionsProvider);

      if (!mounted) return;
      final total = inserted + updated;
      setState(() {
        _importing = false;
        _importStatus = '✓ Importação concluída ($total registros).';
        _previewData = null;
        _duplicates = [];
        _newOnes = [];
      });

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          icon: const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 48,
          ),
          title: const Text('Importação concluída'),
          content: Text(
            'Inseridos: $inserted\n'
            'Atualizados: $updated',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _importing = false;
        _importStatus = '✗ Erro ao salvar no Supabase: $e';
      });
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          icon: const Icon(
            Icons.error_rounded,
            color: AppColors.error,
            size: 48,
          ),
          title: const Text('Falha na importação'),
          content: Text('$e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
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
        .replaceAll(RegExp(r'[^a-z0-9]'), '')
        .trim();
  }
}
