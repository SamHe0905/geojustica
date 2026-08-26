import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../services/quick_exit_service.dart';
import '../../../shared/widgets/geo_app_bar.dart';
import '../../../shared/widgets/geo_icon.dart';

class SafetyCheckScreen extends ConsumerWidget {
  const SafetyCheckScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: GeoAppBar(
        title: 'Antes de tudo',
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextButton.icon(
              onPressed: QuickExitService.leave,
              icon: const GeoIcon('exit', color: Colors.white, size: 16),
              label: const Text('Sair do site'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.ink,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final isWide = c.maxWidth > 600;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? c.maxWidth * 0.2 : 20,
                vertical: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Center(
                            child: GeoIcon('violencia', color: Colors.white, size: 26),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Text(
                            'Você está em segurança agora?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              height: 1.25,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const GeoIcon('exit', color: AppColors.textMuted, size: 15),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          'Se alguém puder estar te vigiando, toque em “Sair do site” a qualquer momento — a página fecha na hora.',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _option(
                    context,
                    '🚨 Não, preciso de socorro',
                    'Vou te conectar com a polícia AGORA',
                    AppColors.error,
                    Icons.emergency_rounded,
                    () => _emergency(context),
                    big: true,
                  ),
                  const SizedBox(height: 12),
                  _option(
                    context,
                    'Sim, quero orientação',
                    'Vamos te ajudar a procurar apoio',
                    AppColors.success,
                    Icons.check_circle_rounded,
                    () {
                      context.push(AppRoutes.results);
                    },
                  ),
                  const SizedBox(height: 12),
                  _option(
                    context,
                    'Só quero ligar 180',
                    'Central de Atendimento à Mulher',
                    AppColors.categoryMulher,
                    Icons.phone_in_talk_rounded,
                    () => _launch('tel:180'),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.secondary,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'O atendimento é gratuito e sigiloso. Você não precisa de advogado para pedir medida protetiva.',
                            style: TextStyle(fontSize: 13, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _option(
    BuildContext context,
    String title,
    String subtitle,
    Color color,
    IconData icon,
    VoidCallback onTap, {
    bool big = false,
  }) {
    return Material(
      color: big ? color.withValues(alpha: 0.05) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(big ? 18 : 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: big ? color : AppColors.divider,
              width: big ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: big ? 52 : 44,
                height: big ? 52 : 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: color, size: big ? 28 : 23),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: big ? 17 : 15,
                        color: AppColors.onBackground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _emergency(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.error,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emergency_rounded, color: Colors.white, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Ligue agora para',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            _emergencyButton(context, '190', 'Polícia Militar'),
            const SizedBox(height: 10),
            _emergencyButton(context, '180', 'Central da Mulher'),
            const SizedBox(height: 14),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Fechar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emergencyButton(BuildContext context, String number, String label) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _launch('tel:$number'),
        icon: const Icon(Icons.phone_in_talk_rounded, size: 28),
        label: Text(
          '$number — $label',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.error,
          padding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  void _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }
}
