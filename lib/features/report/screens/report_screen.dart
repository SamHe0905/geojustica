import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/institution.dart';
import '../../../models/report.dart';
import '../../../providers/institution_provider.dart';
import '../../../providers/report_provider.dart';
import '../../../shared/widgets/geo_app_bar.dart';

class ReportScreen extends ConsumerStatefulWidget {
  final String institutionId;
  const ReportScreen({super.key, required this.institutionId});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  ReportType? _selectedType;
  bool _anonymous = true;
  bool _submitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final instAsync = ref.watch(institutionDetailProvider(widget.institutionId));

    return Scaffold(
      appBar: const GeoAppBar(title: 'Registrar denúncia'),
      body: instAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (inst) {
          if (inst == null) return const Center(child: Text('Instituição não encontrada'));
          return LayoutBuilder(builder: (context, c) {
            final isWide = c.maxWidth > 600;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? c.maxWidth * 0.2 : 20,
                vertical: 24,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(inst),
                    const SizedBox(height: 24),
                    _buildSection('1. Qual o tipo da denúncia?'),
                    const SizedBox(height: 12),
                    _buildTypeSelector(),
                    const SizedBox(height: 24),
                    _buildSection('2. Conte o que aconteceu'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 5,
                      minLines: 4,
                      maxLength: 500,
                      decoration: const InputDecoration(
                        hintText: 'Descreva o ocorrido em detalhes...',
                        alignLabelWithHint: true,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().length < 10) {
                          return 'Por favor, descreva com pelo menos 10 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildSection('3. Identificação (opcional)'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(_anonymous ? Icons.visibility_off_rounded : Icons.person_rounded,
                              color: AppColors.secondary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _anonymous
                                  ? 'Sua denúncia será anônima'
                                  : 'Sua identificação será registrada',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Switch(
                            value: !_anonymous,
                            onChanged: (v) => setState(() => _anonymous = !v),
                            activeThumbColor: AppColors.secondary,
                          ),
                        ],
                      ),
                    ),
                    if (!_anonymous) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Seu nome',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Telefone para contato (opcional)',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: AppColors.warning),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Suas denúncias ajudam a melhorar os serviços públicos de Campo Grande.',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _submitting ? null : _submit,
                      icon: _submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.send_rounded),
                      label: Text(_submitting ? 'Enviando...' : 'Enviar denúncia'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildHeader(Institution inst) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.error.withValues(alpha: 0.9), AppColors.error.withValues(alpha: 0.7)],
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
            child: const Icon(Icons.report_problem_rounded, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Denúncia sobre:',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text(inst.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title) => Text(
        title,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.onBackground),
      );

  Widget _buildTypeSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ReportType.values.map((type) {
        final selected = _selectedType == type;
        return GestureDetector(
          onTap: () => setState(() => _selectedType = type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.divider,
                width: selected ? 2 : 1,
              ),
              boxShadow: selected
                  ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8)]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(type.icon, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  type.label,
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.onBackground,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _submit() async {
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um tipo de denúncia')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    final inst = ref.read(institutionDetailProvider(widget.institutionId)).value;
    if (inst == null) return;

    final report = Report(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      institutionId: inst.id,
      institutionName: inst.name,
      type: _selectedType!,
      description: _descriptionController.text.trim(),
      anonymous: _anonymous,
      contactName: _anonymous ? null : _nameController.text.trim(),
      contactPhone: _anonymous ? null : _phoneController.text.trim(),
    );

    await Future.delayed(const Duration(milliseconds: 600));
    ref.read(reportListProvider.notifier).submit(report);

    if (!mounted) return;
    setState(() => _submitting = false);
    _showSuccess();
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 48),
              ),
              const SizedBox(height: 16),
              const Text(
                'Denúncia registrada!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Sua contribuição ajuda a melhorar o serviço público. Obrigado!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.pop();
                },
                child: const Text('Concluir'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
