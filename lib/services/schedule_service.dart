/// Parser simples de horários: "Seg-Sex 07:30–17:30", "24 horas", etc.
class ScheduleService {
  bool isOpenNow(String? schedule) {
    if (schedule == null || schedule.trim().isEmpty) return false;
    final s = schedule.toLowerCase();

    if (s.contains('24 horas') || s.contains('24h') || s.contains('todos os dias')) {
      return true;
    }

    final now = DateTime.now();
    final weekday = now.weekday; // 1=seg ... 7=dom

    // Verifica dias da semana
    bool inDayRange = false;
    if (RegExp(r'seg.{0,3}sex').hasMatch(s)) {
      inDayRange = weekday >= 1 && weekday <= 5;
    } else if (RegExp(r'seg.{0,3}sab').hasMatch(s)) {
      inDayRange = weekday >= 1 && weekday <= 6;
    } else if (s.contains('seg')) {
      inDayRange = weekday == 1;
    } else {
      inDayRange = true; // assume aberto se não especifica
    }

    if (!inDayRange) return false;

    // Extrai horários "HH:MM"
    final timeRegex = RegExp(r'(\d{1,2}):(\d{2})');
    final matches = timeRegex.allMatches(s).toList();
    if (matches.length < 2) return false;

    final openH = int.parse(matches[0].group(1)!);
    final openM = int.parse(matches[0].group(2)!);
    final closeH = int.parse(matches[1].group(1)!);
    final closeM = int.parse(matches[1].group(2)!);

    final nowMin = now.hour * 60 + now.minute;
    final openMin = openH * 60 + openM;
    final closeMin = closeH * 60 + closeM;

    return nowMin >= openMin && nowMin <= closeMin;
  }

  String openStatus(String? schedule) {
    return isOpenNow(schedule) ? 'Aberto agora' : 'Fechado';
  }
}
