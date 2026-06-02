import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/institution.dart';
import '../../../models/lawyer.dart';
import '../../../providers/lawyer_provider.dart';
import '../../../shared/widgets/geo_app_bar.dart';

class LawyerSignupScreen extends ConsumerStatefulWidget {
  const LawyerSignupScreen({super.key});

  @override
  ConsumerState<LawyerSignupScreen> createState() => _LawyerSignupScreenState();
}

class _LawyerSignupScreenState extends ConsumerState<LawyerSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtl = TextEditingController();
  final _oabCtl = TextEditingController();
  final _bioCtl = TextEditingController();
  final _phoneCtl = TextEditingController();
  final _whatsappCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _addressCtl = TextEditingController();
  final _neighborhoodCtl = TextEditingController();

  final Set<InstitutionCategory> _specialties = {};
  final Set<LawyerModality> _modalities = {};
  bool _submitting = false;

  @override
  void dispose() {
    for (final c in [_nameCtl, _oabCtl, _bioCtl, _phoneCtl, _whatsappCtl, _emailCtl, _addressCtl, _neighborhoodCtl]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GeoAppBar(title: 'Seja um parceiro'),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, c) {
          final isWide = c.maxWidth > 600;
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? c.maxWidth * 0.2 : 20,
              vertical: 20,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _heroCard(),
                  const SizedBox(height: 20),
                  _section('Identificação profissional'),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _nameCtl,
                    decoration: const InputDecoration(
                      labelText: 'Nome completo *',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: _required,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _oabCtl,
                    decoration: const InputDecoration(
                      labelText: 'OAB (ex.: OAB/MS 12345) *',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    validator: _required,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _bioCtl,
                    minLines: 3,
                    maxLines: 5,
                    maxLength: 300,
                    decoration: const InputDecoration(
                      labelText: 'Apresentação curta',
                      alignLabelWithHint: true,
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 60),
                        child: Icon(Icons.info_outline),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _section('Áreas de atuação *'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6, runSpacing: 6,
                    children: InstitutionCategory.values.map((cat) {
                      final selected = _specialties.contains(cat);
                      return FilterChip(
                        label: Text(cat.label),
                        selected: selected,
                        onSelected: (v) => setState(() {
                          v ? _specialties.add(cat) : _specialties.remove(cat);
                        }),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  _section('Modalidades de atendimento'),
                  const SizedBox(height: 8),
                  ...LawyerModality.values.map((m) => CheckboxListTile(
                        value: _modalities.contains(m),
                        onChanged: (v) => setState(() {
                          (v ?? false) ? _modalities.add(m) : _modalities.remove(m);
                        }),
                        title: Text('${m.icon}  ${m.label}'),
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                      )),
                  const SizedBox(height: 16),
                  _section('Contato'),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _phoneCtl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Telefone',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _whatsappCtl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'WhatsApp (com DDD)',
                      prefixIcon: Icon(Icons.chat_outlined),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _emailCtl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _section('Endereço do escritório'),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _addressCtl,
                    decoration: const InputDecoration(
                      labelText: 'Endereço',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _neighborhoodCtl,
                    decoration: const InputDecoration(
                      labelText: 'Bairro *',
                      prefixIcon: Icon(Icons.place_outlined),
                    ),
                    validator: _required,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            color: AppColors.secondary, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Sua inscrição será analisada e a OAB verificada antes da publicação no app.',
                            style: TextStyle(fontSize: 12, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _submitting ? null : _submit,
                    icon: _submitting
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send_rounded),
                    label: Text(_submitting ? 'Enviando...' : 'Enviar inscrição'),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Cancelar'),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _heroCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.secondary, AppColors.secondaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.handshake_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quer ser advogado parceiro?',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900)),
                SizedBox(height: 4),
                Text(
                  'Ajude a ampliar o acesso à justiça em Campo Grande.',
                  style: TextStyle(
                      color: Colors.white,
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

  Widget _section(String title) =>
      Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800));

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_specialties.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione pelo menos uma área de atuação')),
      );
      return;
    }
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 700));

    final lawyer = Lawyer(
      id: 'NEW_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameCtl.text.trim(),
      oab: _oabCtl.text.trim(),
      bio: _bioCtl.text.trim().isEmpty ? null : _bioCtl.text.trim(),
      specialties: _specialties.toList(),
      modalities: _modalities.toList(),
      phone: _phoneCtl.text.trim().isEmpty ? null : _phoneCtl.text.trim(),
      whatsapp: _whatsappCtl.text.trim().isEmpty ? null : _whatsappCtl.text.trim(),
      email: _emailCtl.text.trim().isEmpty ? null : _emailCtl.text.trim(),
      address: _addressCtl.text.trim().isEmpty ? null : _addressCtl.text.trim(),
      neighborhood: _neighborhoodCtl.text.trim(),
      isVerified: false,
      isActive: false, // até verificação
    );
    ref.read(lawyerRepoProvider).add(lawyer);

    if (!mounted) return;
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
                    color: AppColors.success.withOpacity(0.15),
                    shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 48),
              ),
              const SizedBox(height: 16),
              const Text('Inscrição enviada!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text(
                'Sua inscrição será analisada e você receberá um retorno em até 5 dias úteis.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 18),
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
