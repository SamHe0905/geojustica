import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/institution.dart';
import '../../../services/location_service.dart';

class InstitutionCard extends StatefulWidget {
  final Institution institution;

  const InstitutionCard({super.key, required this.institution});

  @override
  State<InstitutionCard> createState() => _InstitutionCardState();
}

class _InstitutionCardState extends State<InstitutionCard> {
  bool _hover = false;

  Color _categoryColor() {
    switch (widget.institution.category) {
      case InstitutionCategory.familia: return AppColors.categoryFamilia;
      case InstitutionCategory.trabalho: return AppColors.categoryTrabalho;
      case InstitutionCategory.violenciaDomestica: return AppColors.categoryViolencia;
      case InstitutionCategory.consumidor: return AppColors.categoryConsumidor;
      case InstitutionCategory.moradia: return AppColors.categoryMoradia;
      case InstitutionCategory.documentos: return AppColors.categoryDocumentos;
      case InstitutionCategory.direitosMulher: return AppColors.categoryMulher;
      case InstitutionCategory.aposentadoria: return AppColors.categoryAposentadoria;
      case InstitutionCategory.outros: return AppColors.categoryOutros;
    }
  }

  @override
  Widget build(BuildContext context) {
    final inst = widget.institution;
    final color = _categoryColor();

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _hover ? color.withValues(alpha: 0.4) : AppColors.divider,
            width: _hover ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _hover ? color.withValues(alpha: 0.2) : AppColors.cardShadow,
              blurRadius: _hover ? 14 : 8,
              offset: Offset(0, _hover ? 5 : 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => context.push('/instituicao/${inst.id}'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color.withValues(alpha: 0.18), color.withValues(alpha: 0.08)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.balance, color: color, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              inst.name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: color,
                                height: 1.25,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              inst.category.label,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (inst.distanceKm != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: color.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.near_me_rounded,
                                  color: color, size: 12),
                              const SizedBox(width: 3),
                              Text(
                                LocationService().formatDistance(inst.distanceKm!),
                                style: TextStyle(
                                  color: color,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  _infoRow(Icons.location_on_outlined,
                      '${inst.address} – ${inst.neighborhood}'),
                  if (inst.schedule != null) ...[
                    const SizedBox(height: 4),
                    _infoRow(Icons.access_time_rounded, inst.schedule!),
                  ],
                  if (inst.acceptsIndigent) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded,
                              color: AppColors.success, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Atendimento gratuito',
                            style: TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (inst.phone != null)
                        _ActionButton(
                          label: 'Ligar',
                          icon: Icons.phone_rounded,
                          color: AppColors.secondary,
                          onTap: () => _launch('tel:${inst.phone}'),
                        ),
                      if (inst.whatsapp != null) ...[
                        const SizedBox(width: 6),
                        _ActionButton(
                          label: 'WhatsApp',
                          icon: Icons.chat_rounded,
                          color: AppColors.whatsapp,
                          onTap: () => _launch('https://wa.me/${inst.whatsapp}'),
                        ),
                      ],
                      const Spacer(),
                      _ActionButton(
                        label: 'Como chegar',
                        icon: Icons.directions_rounded,
                        color: AppColors.primary,
                        onTap: () => _launch(
                          'https://www.google.com/maps/dir/?api=1&destination=${inst.latitude},${inst.longitude}',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.35,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
