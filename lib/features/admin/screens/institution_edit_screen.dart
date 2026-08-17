import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/institution.dart';
import '../../../providers/institution_provider.dart';
import '../../../shared/widgets/geo_app_bar.dart';

/// Edição completa de um órgão — inclusive a categoria, que define em qual
/// fluxo ele aparece para o cidadão.
class InstitutionEditScreen extends ConsumerStatefulWidget {
  final Institution institution;

  const InstitutionEditScreen({super.key, required this.institution});

  @override
  ConsumerState<InstitutionEditScreen> createState() =>
      _InstitutionEditScreenState();
}

class _InstitutionEditScreenState extends ConsumerState<InstitutionEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _address;
  late final TextEditingController _neighborhood;
  late final TextEditingController _phone;
  late final TextEditingController _whatsapp;
  late final TextEditingController _services;
  late final TextEditingController _schedule;
  late final TextEditingController _observations;
  late final TextEditingController _latitude;
  late final TextEditingController _longitude;

  late InstitutionCategory _category;
  late AdminSphere _sphere;
  late bool _acceptsIndigent;
  late bool _isActive;

  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final i = widget.institution;
    _name = TextEditingController(text: i.name);
    _address = TextEditingController(text: i.address);
    _neighborhood = TextEditingController(text: i.neighborhood);
    _phone = TextEditingController(text: i.phone ?? '');
    _whatsapp = TextEditingController(text: i.whatsapp ?? '');
    _services = TextEditingController(text: i.services.join('; '));
    _schedule = TextEditingController(text: i.schedule ?? '');
    _observations = TextEditingController(text: i.observations ?? '');
    _latitude = TextEditingController(text: i.latitude.toString());
    _longitude = TextEditingController(text: i.longitude.toString());
    _category = i.category;
    _sphere = i.sphere;
    _acceptsIndigent = i.acceptsIndigent;
    _isActive = i.isActive;
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _address,
      _neighborhood,
      _phone,
      _whatsapp,
      _services,
      _schedule,
      _observations,
      _latitude,
      _longitude,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    final updated = Institution(
      id: widget.institution.id,
      name: _name.text.trim(),
      address: _address.text.trim(),
      neighborhood: _neighborhood.text.trim(),
      phone: _emptyToNull(_phone.text),
      whatsapp: _emptyToNull(_whatsapp.text),
      category: _category,
      services: _services.text
          .split(';')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      schedule: _emptyToNull(_schedule.text),
      observations: _emptyToNull(_observations.text),
      sphere: _sphere,
      latitude: double.parse(_latitude.text.trim().replaceAll(',', '.')),
      longitude: double.parse(_longitude.text.trim().replaceAll(',', '.')),
      acceptsIndigent: _acceptsIndigent,
      isActive: _isActive,
    );

    try {
      await ref
          .read(institutionRepoProvider)
          .updateOne(widget.institution.id, updated);

      ref.invalidate(adminInstitutionsProvider);
      ref.invalidate(allInstitutionsProvider);
      ref.invalidate(institutionDetailProvider(widget.institution.id));

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Não foi possível salvar: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GeoAppBar(title: 'Editar órgão'),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _sectionTitle('Identificação', Icons.badge_rounded),
              _field(
                controller: _name,
                label: 'Nome *',
                icon: Icons.balance_rounded,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'O nome é obrigatório.'
                    : null,
              ),
              _field(
                controller: _address,
                label: 'Endereço',
                icon: Icons.place_outlined,
              ),
              _field(
                controller: _neighborhood,
                label: 'Bairro',
                icon: Icons.map_outlined,
              ),

              const SizedBox(height: 8),
              _sectionTitle('Classificação', Icons.category_rounded),
              _categoryField(),
              const SizedBox(height: 12),
              _sphereField(),

              const SizedBox(height: 8),
              _sectionTitle('Contato', Icons.call_rounded),
              _field(
                controller: _phone,
                label: 'Telefone',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              _field(
                controller: _whatsapp,
                label: 'WhatsApp (só números, com DDD)',
                icon: Icons.chat_outlined,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 8),
              _sectionTitle('Atendimento', Icons.info_outline_rounded),
              _field(
                controller: _services,
                label: 'Serviços (separados por ;)',
                icon: Icons.checklist_rounded,
                maxLines: 3,
              ),
              _field(
                controller: _schedule,
                label: 'Horário',
                icon: Icons.schedule_rounded,
              ),
              _field(
                controller: _observations,
                label: 'Observações',
                icon: Icons.sticky_note_2_outlined,
                maxLines: 3,
              ),

              const SizedBox(height: 8),
              _sectionTitle('Localização no mapa', Icons.my_location_rounded),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      controller: _latitude,
                      label: 'Latitude *',
                      icon: Icons.north_rounded,
                      keyboardType:
                          const TextInputType.numberWithOptions(signed: true, decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,\-]')),
                      ],
                      validator: _coordValidator(-90, 90),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _field(
                      controller: _longitude,
                      label: 'Longitude *',
                      icon: Icons.east_rounded,
                      keyboardType:
                          const TextInputType.numberWithOptions(signed: true, decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,\-]')),
                      ],
                      validator: _coordValidator(-180, 180),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              _sectionTitle('Situação', Icons.toggle_on_rounded),
              SwitchListTile(
                value: _acceptsIndigent,
                onChanged: (v) => setState(() => _acceptsIndigent = v),
                title: const Text('Atende gratuitamente'),
                subtitle: const Text(
                    'Aparece para quem respondeu que não pode pagar advogado.'),
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
                title: const Text('Ativo'),
                subtitle: const Text(
                    'Desativado, o órgão some das buscas e do mapa do cidadão.'),
                contentPadding: EdgeInsets.zero,
              ),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                        color: AppColors.error, fontWeight: FontWeight.w600),
                  ),
                ),
              ],

              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save_rounded),
                label: Text(_saving ? 'Salvando...' : 'Salvar alterações'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed:
                    _saving ? null : () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? Function(String?) _coordValidator(double min, double max) {
    return (value) {
      final raw = (value ?? '').trim().replaceAll(',', '.');
      if (raw.isEmpty) return 'Obrigatório.';
      final parsed = double.tryParse(raw);
      if (parsed == null) return 'Número inválido.';
      if (parsed < min || parsed > max) return 'Fora de $min a $max.';
      return null;
    };
  }

  Widget _sectionTitle(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(text,
              style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          alignLabelWithHint: maxLines > 1,
        ),
      ),
    );
  }

  Widget _categoryField() {
    return DropdownButtonFormField<InstitutionCategory>(
      initialValue: _category,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Categoria *',
        prefixIcon: Icon(Icons.category_outlined),
        helperText: 'Define em qual fluxo o órgão aparece para o cidadão.',
        helperMaxLines: 2,
      ),
      items: InstitutionCategory.values
          .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
          .toList(),
      onChanged: (v) {
        if (v != null) setState(() => _category = v);
      },
    );
  }

  Widget _sphereField() {
    return DropdownButtonFormField<AdminSphere>(
      initialValue: _sphere,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Esfera',
        prefixIcon: Icon(Icons.account_balance_outlined),
      ),
      items: AdminSphere.values
          .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
          .toList(),
      onChanged: (v) {
        if (v != null) setState(() => _sphere = v);
      },
    );
  }
}
