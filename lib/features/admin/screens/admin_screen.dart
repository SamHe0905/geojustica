import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/institution.dart';
import '../../../models/report.dart';
import '../../../providers/institution_provider.dart';
import '../../../providers/report_provider.dart';
import '../../../services/excel_import_service.dart';
import '../../../shared/widgets/geo_app_bar.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _importing = false;
  String? _importStatus;
  List<Institution>? _previewData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reports = ref.watch(reportListProvider);

    return Scaffold(
      appBar: GeoAppBar(
        title: 'Painel Administrativo',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () => ref.invalidate(allInstitutionsProvider),
          ),
        ],
      ),
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
                const Tab(icon: Icon(Icons.upload_file_rounded), text: 'Importar'),
                const Tab(icon: Icon(Icons.list_alt_rounded), text: 'Instituições'),
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
                                horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${reports.length}',
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                    ],
                  ),
                  text: 'Denúncias',
                ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsTab(List<Report> reports) {
    if (reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified_rounded,
                  color: AppColors.success, size: 48),
            ),
            const SizedBox(height: 16),
            const Text('Nenhuma denúncia registrada',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 4),
            const Text('Tudo certo por aqui!',
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Total',
                value: reports.length.toString(),
                color: AppColors.primary,
                icon: Icons.flag_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'Pendentes',
                value: reports
                    .where((r) => r.status == ReportStatus.pendente)
                    .length
                    .toString(),
                color: AppColors.warning,
                icon: Icons.pending_actions_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...reports.map((r) => _ReportCard(report: r)),
      ],
    );
  }

  Widget _buildImportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Colunas esperadas:',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                SizedBox(height: 8),
                Text(
                  'nome, endereco, bairro, telefone, whatsapp, categoria,\n'
                  'servicos, horario, observacoes, esfera,\n'
                  'latitude, longitude, atende_gratuito, ativo',
                  style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _importing ? null : _pickAndImport,
            icon: _importing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.upload_file_rounded),
            label: Text(_importing ? 'Importando...' : 'Selecionar arquivo Excel'),
          ),
          if (_importStatus != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _importStatus!.startsWith('✓')
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _importStatus!,
                style: TextStyle(
                  color: _importStatus!.startsWith('✓')
                      ? AppColors.success
                      : AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          if (_previewData != null) ...[
            const SizedBox(height: 24),
            Text('Prévia (${_previewData!.length} registros):',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            ..._previewData!.take(5).map((inst) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(inst.name),
                    subtitle: Text('${inst.neighborhood} • ${inst.category.label}'),
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildInstitutionsTab() {
    final institutionsAsync = ref.watch(allInstitutionsProvider);
    return institutionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erro: $e')),
      data: (institutions) {
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: institutions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 4),
          itemBuilder: (context, i) {
            final inst = institutions[i];
            return Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.balance, color: AppColors.primary, size: 20),
                ),
                title: Text(inst.name,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('${inst.category.label} • ${inst.neighborhood}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Ativo',
                    style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                        fontSize: 12),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pickAndImport() async {
    setState(() {
      _importing = true;
      _importStatus = null;
      _previewData = null;
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
      final institutions =
          ExcelImportService().parseExcel(result.files.single.bytes!);
      setState(() {
        _importing = false;
        _previewData = institutions;
        _importStatus = '✓ ${institutions.length} registros lidos.';
      });
    } catch (e) {
      setState(() {
        _importing = false;
        _importStatus = '✗ Erro: $e';
      });
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w900, color: color)),
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final Report report;
  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(report.type.icon, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    report.type.label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(report.status.name,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.warning)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(report.institutionName,
                style: const TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(report.description,
                maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(report.anonymous ? Icons.visibility_off : Icons.person,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  report.anonymous ? 'Anônimo' : (report.contactName ?? 'Identificado'),
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
                const Spacer(),
                Text(_formatDate(report.createdAt),
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
