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
  InstitutionCategory? _detectedCategory;
  bool _listening = false;
  StreamSubscription<String>? _voiceSub;
  late AnimationController _pulseController;

  final List<String> _suggestions = [
    'meu patrão não pagou',
    'preciso de pensão',
    'violência em casa',
    'problema com aluguel',
    'não tenho documento',
    'quero me aposentar',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _voiceSub?.cancel();
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onSearch(String text) {
    final category = _keywordService.detect(text);
    setState(() => _detectedCategory = category);
    if (category != null) {
      ref.read(flowProvider.notifier).reset();
      ref.read(flowProvider.notifier).setCategory(category);
      context.push(AppRoutes.flow);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não consegui entender. Tente reformular ou escolha uma categoria.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _onTextChanged(String v) {
    final cat = _keywordService.detect(v);
    if (cat != _detectedCategory) setState(() => _detectedCategory = cat);
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
          content: Text('Seu navegador não suporta ditado por voz. Use o Chrome ou Edge.'),
        ),
      );
      return;
    }

    setState(() => _listening = true);
    try {
      _voiceSub = _voiceService.listen().listen(
        (text) {
          _controller.text = text;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: text.length),
          );
          _onTextChanged(text);
        },
        onError: (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: $e')),
          );
          setState(() => _listening = false);
        },
        onDone: () {
          setState(() => _listening = false);
        },
      );
    } catch (e) {
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
              vertical: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Descreva sua situação',
                    style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 8),
                Text(
                  'Pode escrever com suas próprias palavras ou usar o microfone 🎙️',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 24),
                _buildSearchBox(),
                if (_listening) ...[
                  const SizedBox(height: 12),
                  _buildListeningIndicator(),
                ],
                if (_detectedCategory != null) ...[
                  const SizedBox(height: 12),
                  _buildDetectionHint(),
                ],
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _controller.text.isNotEmpty
                      ? () => _onSearch(_controller.text)
                      : null,
                  icon: const Icon(Icons.search_rounded),
                  label: const Text('Buscar instituições'),
                ),
                const SizedBox(height: 28),
                Text('Exemplos de busca:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textSecondary,
                        )),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _suggestions.map((s) {
                    return ActionChip(
                      label: Text(s),
                      onPressed: () {
                        _controller.text = s;
                        _onSearch(s);
                      },
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: AppColors.divider),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
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
        hintText: 'Ex: "meu patrão não me pagou o salário"',
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
      onSubmitted: _onSearch,
    );
  }

  Widget _buildListeningIndicator() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, __) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.08 + _pulseController.value * 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withOpacity(0.4), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Estou ouvindo... pode falar.',
                style: TextStyle(
                    fontWeight: FontWeight.w700, color: AppColors.error),
              ),
            ),
            TextButton(
              onPressed: _toggleListen,
              child: const Text('Parar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectionHint() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_fix_high_rounded, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Identifiquei: ${_detectedCategory!.label}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.secondary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Pode escrever errado, sem acentos ou abreviado — o app entende. Ex: "viol em casa" funciona como "violência em casa".',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
