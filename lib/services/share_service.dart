import 'package:url_launcher/url_launcher.dart';
import '../models/institution.dart';

class ShareService {
  String formatInstitution(Institution inst) {
    final lines = <String>[
      '📍 *${inst.name}*',
      '',
      '🏢 ${inst.address}',
      '📌 Bairro: ${inst.neighborhood}',
    ];
    if (inst.phone != null) lines.add('📞 ${inst.phone}');
    if (inst.whatsapp != null) lines.add('💬 WhatsApp: ${inst.whatsapp}');
    if (inst.schedule != null) lines.add('🕒 ${inst.schedule}');
    if (inst.acceptsIndigent) lines.add('✅ Atendimento gratuito');
    lines.add('');
    lines.add(
        '🗺️ Como chegar: https://www.google.com/maps/dir/?api=1&destination=${inst.latitude},${inst.longitude}');
    lines.add('');
    lines.add('Encontrado no app *GeoJustiça*');
    return lines.join('\n');
  }

  Future<void> shareViaWhatsApp(Institution inst) async {
    final text = Uri.encodeComponent(formatInstitution(inst));
    final uri = Uri.parse('https://wa.me/?text=$text');
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
