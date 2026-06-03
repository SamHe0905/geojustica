import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../models/institution.dart';
import '../../../providers/flow_provider.dart';
import '../../../services/keyword_service.dart';
import '../../../services/voice_service.dart';
import '../../../shared/widgets/geo_app_bar.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _keywordService = KeywordService();
  final _voiceService = VoiceService();

  List<DetectionMatch> _matches = [];
  List<String> _suggestions = [];
  bool _listening = false;
  StreamSubscription<String>? _voiceSub;
  Timer? _debounce;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _suggestions = _keywordService.suggestionsFor('');
  }

  @override
  void dispose() {
    _voiceSub?.cancel();
    _controller.dispose();
    _pulseController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onTextChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      setState(() {
        _matches = _keywordService.detectAll(v);
        _suggestions = _keywordService.suggestionsFor(v);
      });
    });
  }

  void _goToCategory(InstitutionCategory category, {String? subcategoryId}) {
    ref.read(flowProvider.notifier).reset();
    ref.read(flowProvider.notifier).setCategory(category);
    if (subcategoryId != null) {
      ref.read(flowProvider.notifier).setSubcategory(subcategoryId);
      context.push(AppRoutes.flow);
    } else {
      if (category == InstitutionCategory.violenciaDomestica) {
        context.push(AppRoutes.safetyCheck);
      } else {
        context.push(AppRoutes.subcategory);
      }
    }
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final list = _keywordService.detectAll(text);
    if (list.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Não consegui entender. Tente palavras mais simples ou escolha uma categoria.'),
        ),
      );
      return;
    }
    final best = list.first;
    _goToCategory(best.category, subcategoryId: best.subcategoryId);
  }

  Future<void> _toggleListen() async {
    if (_listening) {
      _voiceService.stop();
      setState(() => _listening = false);
      return;
    }
    if (!_voiceService.isSupported) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Seu navegador não suporta ditado por voz. Use o Chrome ou Edge.')),
      );
      return;
    }
    setState(() => _listening = true);
    try {
      _voiceSub = _voiceService.listen().listen((text) {
        _controller.text = text;
        _controller.selection =
            TextSelection.fromPosition(TextPosition(offset: text.length));
        _onTextChanged(text);
      }, onError: (e) {
        setState(() => _listening = false);
      }, onDone: () {
        setState(() => _listening = false);
      });
    } catch (_) {
      setState(() => _listening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GeoAppBar(title: 'Buscar ajuda'),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? constraints.maxWidth * 0.2 : 20,
              vertical: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Descreva sua situação',
                    style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 6),
                const Text(
                  'Pode escrever com suas próprias palavras ou usar o microfone 🎙️',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 18),
                _buildSearchBox(),
                if (_listening) ...[
                  const SizedBox(height: 10),
                  _buildListeningIndicator(),
                ],
                const SizedBox(height: 14),
                if (_matches.isNotEmpty) _buildResults(),
                if (_matches.isEmpty && _controller.text.isEmpty)
                  _buildSuggestions(),
                if (_matches.isEmpty && _controller.text.isNotEmpty)
                  _buildLiveSuggestions(),
                const SizedBox(height: 18),
                if (_controller.text.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.search_rounded),
                    label: const Text('Buscar instituições'),
                  ),
                const SizedBox(height: 18),
                _buildHelpBox(),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSearchBox() {
    return TextField(
      controller: _controller,
      autofocus: true,
      maxLines: 3,
      minLines: 2,
      decoration: InputDecoration(
        hintText: 'Ex: "meu patrão não pagou meu salário"',
        prefixIcon: const Padding(
          padding: EdgeInsets.only(bottom: 40),
          child: Icon(Icons.search_rounded, color: AppColors.primary),
        ),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(bottom: 40, right: 8),
          child: AnimatedScale(
            scale: _listening ? 1.15 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Material(
              color: _listening ? AppColors.error : AppColors.primary,
              shape: const CircleBorder(),
              elevation: _listening ? 6 : 2,
              child: InkWell(
                onTap: _toggleListen,
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    _listening ? Icons.stop_rounded : Icons.mic_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      onChanged: _onTextChanged,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => _submit(),
    );
  }

  Widget _buildListeningIndicator() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, __) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08 + _pulseController.value * 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 12, height: 12,
              decoration: const BoxDecoration(
                  color: AppColors.error, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('Estou ouvindo... pode falar.',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: AppColors.error)),
            ),
            TextButton(
                onPressed: _toggleListen, child: const Text('Parar')),
          ],
        ),
      ),
    );
  }

  // Tela de resultados de detecção
  Widget _buildResults() {
    final best = _matches.first;
    final others = _matches.skip(1).take(2).toList();
    final confidenceColor = best.score >= 6
        ? AppColors.success
        : best.score >= 3
            ? AppColors.warning
            : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.12),
                AppColors.primary.withValues(alpha: 0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_fix_high_rounded,
                      color: AppColors.primary, size: 22),
                  const SizedBox(width: 8),
                  const Text('Identifiquei sua situação',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: AppColors.primary)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: confidenceColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('confiança ${best.confidence}',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: confidenceColor)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _MatchTile(
                match: best,
                primary: true,
                onTap: () => _goToCategory(best.category,
                    subcategoryId: best.subcategoryId),
              ),
            ],
          ),
        ),
        if (others.isNotEmpty) ...[
          const SizedBox(height: 14),
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text(
              'Pode ser também:',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 6),
          ...others.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _MatchTile(
                  match: m,
                  primary: false,
                  onTap: () =>
                      _goToCategory(m.category, subcategoryId: m.subcategoryId),
                ),
              )),
        ],
      ],
    );
  }

  Widget _buildSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Exemplos de busca:',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _suggestions
              .map((s) => ActionChip(
                    label: Text(s, style: const TextStyle(fontSize: 12.5)),
                    onPressed: () {
                      _controller.text = s;
                      _onTextChanged(s);
                    },
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.divider),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildLiveSuggestions() {
    if (_suggestions.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.lightbulb_outline_rounded,
                color: AppColors.primary, size: 16),
            SizedBox(width: 6),
            Text('Talvez você queira dizer:',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppColors.primary)),
          ]),
          const SizedBox(height: 6),
          ..._suggestions.take(4).map((s) => InkWell(
                onTap: () {
                  _controller.text = s;
                  _onTextChanged(s);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.north_west_rounded,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(s,
                            style: const TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildHelpBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppColors.secondary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Pode escrever errado, sem acentos ou abreviado. Pode usar gírias ("meu chefe", "tô devendo", "pai do meu filho"). O app entende.',
              style:
                  TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchTile extends StatelessWidget {
  final DetectionMatch match;
  final bool primary;
  final VoidCallback onTap;
  const _MatchTile(
      {required this.match, required this.primary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = primary ? AppColors.primary : AppColors.textSecondary;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: primary ? 2 : 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: primary ? color.withValues(alpha: 0.3) : AppColors.divider,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(_iconFor(match.category), color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      match.category.label,
                      style: TextStyle(
                        fontSize: primary ? 16 : 14,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    if (match.subcategoryId != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _subLabel(match.subcategoryId!),
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: color, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(InstitutionCategory cat) {
    switch (cat) {
      case InstitutionCategory.familia: return Icons.family_restroom_rounded;
      case InstitutionCategory.trabalho: return Icons.work_rounded;
      case InstitutionCategory.violenciaDomestica: return Icons.shield_rounded;
      case InstitutionCategory.consumidor: return Icons.shopping_bag_rounded;
      case InstitutionCategory.moradia: return Icons.home_rounded;
      case InstitutionCategory.documentos: return Icons.badge_rounded;
      case InstitutionCategory.direitosMulher: return Icons.female_rounded;
      case InstitutionCategory.aposentadoria: return Icons.elderly_rounded;
      case InstitutionCategory.saude: return Icons.local_hospital_rounded;
      case InstitutionCategory.denuncias: return Icons.campaign_rounded;
      case InstitutionCategory.outros: return Icons.help_rounded;
    }
  }

  String _subLabel(String id) {
    // Mapa simples — a label real está no SubcategoryRegistry,
    // mas pra evitar import circular fazemos mapping inline.
    const map = {
      'pensao': 'Pensão alimentícia',
      'divorcio': 'Divórcio ou separação',
      'guarda': 'Guarda dos filhos',
      'paternidade': 'Reconhecimento de paternidade',
      'inventario': 'Inventário ou herança',
      'demissao': 'Demissão / rescisão',
      'salario': 'Salário não pago',
      'acidente': 'Acidente de trabalho',
      'horas_extras': 'Horas extras',
      'fgts': 'FGTS / direitos trabalhistas',
      'cobranca': 'Cobrança indevida',
      'defeito': 'Produto com defeito',
      'plano_saude': 'Plano de saúde',
      'banco': 'Banco / financeira',
      'telecom': 'Telefone / internet',
      'inquilino': 'Problema com aluguel',
      'despejo': 'Despejo',
      'regularizar': 'Regularizar imóvel',
      'mcmv': 'Minha Casa Minha Vida',
      'rg_cpf': 'RG ou CPF',
      'certidao_nascimento': 'Certidão de nascimento/casamento',
      'certidao_obito': 'Certidão de óbito',
      'titulo_eleitor': 'Título de eleitor',
      'passaporte': 'Passaporte',
      'discriminacao_trabalho': 'Discriminação no trabalho',
      'gravidez': 'Direitos na gravidez',
      'maternidade_d': 'Licença-maternidade',
      'aposentadoria_geral': 'Aposentadoria',
      'auxilio_doenca': 'Auxílio-doença',
      'bpc': 'BPC/LOAS',
      'pensao_morte': 'Pensão por morte',
      'maternidade': 'Salário-maternidade',
      'medicamento': 'Medicamento de alto custo',
      'internacao': 'Internação',
      'cirurgia': 'Cirurgia',
      'tratamento': 'Tratamento negado',
      'consulta': 'Consulta especialista',
      'servico_publico': 'Serviço público ruim',
      'corrupcao': 'Corrupção',
      'ambiental': 'Crime ambiental',
      'oab': 'Denúncia à OAB',
      'maus_tratos': 'Maus tratos / abuso',
      'anonima': 'Denúncia anônima',
    };
    return map[id] ?? id;
  }
}
