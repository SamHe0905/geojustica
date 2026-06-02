import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../models/institution.dart';
import '../../../providers/history_provider.dart';
import '../../../providers/institution_provider.dart';
import '../../../services/schedule_service.dart';
import '../../../services/share_service.dart';
import '../../../services/tts_service.dart';
import '../../../shared/widgets/geo_app_bar.dart';

class InstitutionDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const InstitutionDetailScreen({super.key, required this.id});

  @override
  ConsumerState<InstitutionDetailScreen> createState() =>
      _InstitutionDetailScreenState();
}

class _InstitutionDetailScreenState
    extends ConsumerState<InstitutionDetailScreen> {
  final _tts = TtsService();
  final _share = ShareService();
  final _schedule = ScheduleService();
  bool _ttsActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(historyProvider.notifier).markVisited(widget.id);
    });
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  void _toggleTts(Institution inst) {
    if (_ttsActive) {
      _tts.stop();
      setState(() => _ttsActive = false);
      return;
    }
    final text = [
      inst.name,
      'Endereço: ${inst.address}, bairro ${inst.neighborhood}.',
      if (inst.phone != null) 'Telefone: ${inst.phone}.',
      if (inst.schedule != null) 'Horário: ${inst.schedule}.',
      if (inst.services.isNotEmpty) 'Serviços: ${inst.services.join(', ')}.',
      if (inst.acceptsIndigent) 'Atendimento gratuito.',
    ].join(' ');
    _tts.speak(text);
    setState(() => _ttsActive = true);
  }

  @override
  Widget build(BuildContext context) {
    final instAsync = ref.watch(institutionDetailProvider(widget.id));
    final history = ref.watch(historyProvider);

    return Scaffold(
      appBar: GeoAppBar(
        title: 'Detalhes',
        actions: [
          instAsync.maybeWhen(
            data: (inst) => inst == null
                ? const SizedBox.shrink()
                : IconButton(
                    icon: Icon(
                      _ttsActive
                          ? Icons.volume_up_rounded
                          : Icons.volume_up_outlined,
                      color: Colors.white,
                    ),
                    tooltip: 'Ouvir',
                    onPressed: () => _toggleTts(inst),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
          instAsync.maybeWhen(
            data: (inst) => inst == null
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.share_rounded, color: Colors.white),
                    tooltip: 'Compartilhar',
                    onPressed: () => _share.shareViaWhatsApp(inst),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: instAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (inst) {
          if (inst == null) {
            return const Center(child: Text('Instituição não encontrada.'));
          }
          final isOpen = _schedule.isOpenNow(inst.schedule);
          final currentRating = history.ratings[inst.id];

          return LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? constraints.maxWidth * 0.2 : 20,
                vertical: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(inst, isOpen),
                  const SizedBox(height: 20),
                  _InfoTile(
                    icon: Icons.location_on_rounded,
                    label: 'Endereço',
                    value: '${inst.address}\n${inst.neighborhood}',
                  ),
                  if (inst.phone != null)
                    _InfoTile(
                      icon: Icons.phone_rounded,
                      label: 'Telefone',
                      value: inst.phone!,
                      onTap: () => _launch('tel:${inst.phone}'),
                    ),
                  if (inst.schedule != null)
                    _InfoTile(
                      icon: Icons.access_time_rounded,
                      label: 'Horário (${isOpen ? "Aberto agora" : "Fechado"})',
                      value: inst.schedule!,
                    ),
                  if (inst.services.isNotEmpty)
                    _InfoTile(
                      icon: Icons.checklist_rounded,
                      label: 'Serviços oferecidos',
                      value: inst.services.map((s) => '• $s').join('\n'),
                    ),
                  if (inst.observations != null)
                    _InfoTile(
                      icon: Icons.info_outline_rounded,
                      label: 'Observações',
                      value: inst.observations!,
                    ),
                  const SizedBox(height: 24),
                  _buildRatingSection(inst.id, currentRating),
                  const SizedBox(height: 24),
                  if (inst.phone != null)
                    ElevatedButton.icon(
                      onPressed: () => _launch('tel:${inst.phone}'),
                      icon: const Icon(Icons.phone_rounded),
                      label: const Text('Ligar agora'),
                    ),
                  const SizedBox(height: 12),
                  if (inst.whatsapp != null)
                    ElevatedButton.icon(
                      onPressed: () => _launch('https://wa.me/${inst.whatsapp}'),
                      icon: const Icon(Icons.chat_rounded),
                      label: const Text('Abrir WhatsApp'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.whatsapp),
                    ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _launch(
                        'https://www.google.com/maps/dir/?api=1&destination=${inst.latitude},${inst.longitude}'),
                    icon: const Icon(Icons.directions_rounded),
                    label: const Text('Como chegar'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _share.shareViaWhatsApp(inst),
                    icon: const Icon(Icons.share_rounded),
                    label: const Text('Compartilhar via WhatsApp'),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.error.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.report_problem_rounded,
                                color: AppColors.error, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text('Problemas no atendimento?',
                                  style: TextStyle(
                                      fontSize: 15, fontWeight: FontWeight.w800)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Registre uma denúncia para ajudar a melhorar este serviço.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () =>
                              context.push(AppRoutes.reportFor(inst.id)),
                          icon: const Icon(Icons.flag_rounded),
                          label: const Text('Fazer denúncia'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error, width: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildHeader(Institution inst, bool isOpen) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isOpen ? Colors.green : Colors.red).shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOpen ? 'ABERTO AGORA' : 'FECHADO',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  inst.category.label.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(inst.name,
              style: Theme.of(context)
                  .textTheme
                  .displayMedium
                  ?.copyWith(color: Colors.white)),
          const SizedBox(height: 8),
          if (inst.acceptsIndigent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text('Atendimento Gratuito',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRatingSection(String id, int? currentRating) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          const Text(
            'Você foi bem atendido aqui?',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ratingButton(
                icon: Icons.thumb_up_rounded,
                label: 'Sim',
                color: AppColors.success,
                selected: currentRating == 1,
                onTap: () =>
                    ref.read(historyProvider.notifier).rate(id, 1),
              ),
              const SizedBox(width: 14),
              _ratingButton(
                icon: Icons.thumb_down_rounded,
                label: 'Não',
                color: AppColors.error,
                selected: currentRating == -1,
                onTap: () =>
                    ref.read(historyProvider.notifier).rate(id, -1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ratingButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected ? color : color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: selected ? Colors.white : color, size: 20),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                      color: selected ? Colors.white : color,
                      fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }

  void _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final VoidCallback? onTap;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            )),
                    const SizedBox(height: 2),
                    Text(value,
                        style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(Icons.open_in_new_rounded,
                    size: 16, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
