import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';

class SosButton extends StatelessWidget {
  const SosButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: 'sos',
      onPressed: () => _openSosSheet(context),
      backgroundColor: AppColors.error,
      foregroundColor: Colors.white,
      elevation: 6,
      icon: const Icon(Icons.emergency_rounded),
      label: const Text('SOS',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
    );
  }

  void _openSosSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.emergency_rounded,
                      color: AppColors.error, size: 28),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Emergência',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w900)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Se você ou alguém está em perigo agora, ligue:',
              style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            _sosCard(context, '190', 'Polícia Militar',
                'Emergência policial em curso', Icons.local_police_rounded,
                AppColors.secondary),
            const SizedBox(height: 10),
            _sosCard(context, '192', 'SAMU',
                'Atendimento médico urgente', Icons.medical_services_rounded,
                Colors.red.shade700),
            const SizedBox(height: 10),
            _sosCard(context, '193', 'Bombeiros',
                'Incêndio, resgate', Icons.local_fire_department_rounded,
                Colors.orange.shade800),
            const SizedBox(height: 10),
            _sosCard(context, '180', 'Central da Mulher',
                'Violência contra a mulher', Icons.female_rounded,
                AppColors.categoryMulher),
            const SizedBox(height: 10),
            _sosCard(context, '181', 'Disque Denúncia',
                'Denúncia anônima', Icons.shield_rounded,
                AppColors.warning),
            const SizedBox(height: 10),
            _sosCard(context, '100', 'Direitos Humanos',
                'Violações de direitos', Icons.handshake_rounded,
                AppColors.success),
          ],
        ),
      ),
    );
  }

  Widget _sosCard(BuildContext context, String number, String name,
      String desc, IconData icon, Color color) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          final uri = Uri.parse('tel:$number');
          if (await canLaunchUrl(uri)) launchUrl(uri);
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.12), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(number,
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: color)),
                        const SizedBox(width: 8),
                        Text(name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 15)),
                      ],
                    ),
                    Text(desc,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.phone_rounded, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
