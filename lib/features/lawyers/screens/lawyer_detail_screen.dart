import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/lawyer_provider.dart';
import '../../../shared/widgets/geo_app_bar.dart';

class LawyerDetailScreen extends ConsumerWidget {
  final String id;
  const LawyerDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lawyer = ref.watch(lawyerByIdProvider(id));
    if (lawyer == null) {
      return const Scaffold(
        appBar: GeoAppBar(title: 'Advogado'),
        body: Center(child: Text('Advogado não encontrado')),
      );
    }

    return Scaffold(
      appBar: const GeoAppBar(title: 'Advogado parceiro'),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, c) {
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
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white,
                        child: Text(
                          lawyer.initials,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    lawyer.name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900),
                                  ),
                                ),
                                if (lawyer.isVerified) ...[
                                  const SizedBox(width: 6),
                                  const Icon(Icons.verified_rounded,
                                      color: Colors.white, size: 18),
                                ],
                              ],
                            ),
                            Text(lawyer.oab,
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 13)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    color: AppColors.accent, size: 18),
                                Text(' ${lawyer.rating.toStringAsFixed(1)}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800)),
                                Text(' • ${lawyer.ratingCount} avaliações',
                                    style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.8),
                                        fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (lawyer.bio != null) ...[
                  _section('Sobre'),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(lawyer.bio!,
                        style: const TextStyle(fontSize: 15, height: 1.4)),
                  ),
                  const SizedBox(height: 12),
                ],
                _section('Áreas de atuação'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: lawyer.specialties
                      .map((s) => Chip(
                            label: Text(s.label),
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.1),
                            labelStyle: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                _section('Modalidades de atendimento'),
                const SizedBox(height: 8),
                ...lawyer.modalities.map((m) => Container(
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Text(m.icon, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(m.label,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 16),
                if (lawyer.languages.length > 1) ...[
                  _section('Idiomas / Acessibilidade'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: lawyer.languages
                        .map((l) => Chip(label: Text(l)))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                ],
                if (lawyer.address != null) ...[
                  _section('Escritório'),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.location_on_rounded,
                          color: AppColors.primary),
                      title: Text(lawyer.address!),
                      subtitle: Text(lawyer.neighborhood),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (lawyer.whatsapp != null)
                  ElevatedButton.icon(
                    onPressed: () => _launch(
                        'https://wa.me/${lawyer.whatsapp}?text=${Uri.encodeComponent("Olá! Encontrei seu perfil no GeoJustiça e gostaria de uma orientação.")}'),
                    icon: const Icon(Icons.chat_rounded),
                    label: const Text('Falar pelo WhatsApp'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.whatsapp),
                  ),
                const SizedBox(height: 10),
                if (lawyer.phone != null)
                  OutlinedButton.icon(
                    onPressed: () => _launch('tel:${lawyer.phone}'),
                    icon: const Icon(Icons.phone_rounded),
                    label: const Text('Ligar'),
                  ),
                const SizedBox(height: 10),
                if (lawyer.email != null)
                  OutlinedButton.icon(
                    onPressed: () => _launch('mailto:${lawyer.email}'),
                    icon: const Icon(Icons.email_rounded),
                    label: const Text('Enviar e-mail'),
                  ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: AppColors.warning, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'O GeoJustiça apenas conecta usuários a advogados parceiros. '
                          'A relação contratual é exclusivamente entre você e o profissional.',
                          style: TextStyle(fontSize: 12, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _section(String title) => Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
      );

  void _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
