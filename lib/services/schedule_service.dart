/// Parser de horários: "Seg-Sex 07:30–13:30", "24 horas", "08:00–12:00 / 13:00–17:00"
class ScheduleService {
  /// Retorna se está aberto AGORA com base no horário atual e no string.
  bool isOpenNow(String? schedule) {
    if (schedule == null || schedule.trim().isEmpty) return false;
    final s = _normalize(schedule);

    // Casos especiais: 24h
    if (s.contains('24 horas') ||
        s.contains('24h') ||
        s.contains('todos os dias') && _hasNoTimeRange(s)) {
      return true;
    }

    final now = DateTime.now();
    final weekday = now.weekday; // 1=seg ... 7=dom

    // Verifica dias da semana ANTES de checar horário
    if (!_isDayInRange(s, weekday)) return false;

    // Extrai todos os intervalos de horário (HH:MM até HH:MM)
    final intervals = _extractTimeIntervals(s);
    if (intervals.isEmpty) return true; // sem horário => assume aberto

    final nowMin = now.hour * 60 + now.minute;
    return intervals.any((iv) => nowMin >= iv.start && nowMin <= iv.end);
  }

  /// Próximo horário de abertura (em texto amigável).
  String? nextOpening(String? schedule) {
    if (schedule == null || schedule.trim().isEmpty) return null;
    if (isOpenNow(schedule)) return null;
    final s = _normalize(schedule);
    final intervals = _extractTimeIntervals(s);
    if (intervals.isEmpty) return null;

    final now = DateTime.now();
    final nowMin = now.hour * 60 + now.minute;
    final isWorkday = now.weekday >= 1 && now.weekday <= 5;
    final isFriday = now.weekday == 5;
    final isWeekend = now.weekday >= 6;

    // Tenta encontrar próximo intervalo ainda hoje
    if (_isDayInRange(s, now.weekday)) {
      for (final iv in intervals) {
        if (nowMin < iv.start) {
          return 'Abre às ${_formatMinutes(iv.start)}';
        }
      }
    }

    // Senão, amanhã (ou segunda)
    if (isWeekend) return 'Abre segunda-feira';
    if (isFriday) return 'Abre segunda-feira';
    if (isWorkday) return 'Abre amanhã';
    return null;
  }

  String openStatus(String? schedule) =>
      isOpenNow(schedule) ? 'Aberto agora' : 'Fechado';

  // -------- helpers --------

  String _normalize(String s) {
    return s
        .toLowerCase()
        .replaceAll('–', '-')
        .replaceAll('—', '-')
        .replaceAll('às', 'as')
        .trim();
  }

  bool _hasNoTimeRange(String s) {
    return !RegExp(r'\d{1,2}:\d{2}').hasMatch(s);
  }

  bool _isDayInRange(String s, int weekday) {
    // Casos comuns
    if (s.contains('24 horas')) return true;
    if (s.contains('todos os dias')) return true;

    if (RegExp(r'seg.{0,4}sex').hasMatch(s)) {
      return weekday >= 1 && weekday <= 5;
    }
    if (RegExp(r'seg.{0,4}sab').hasMatch(s)) {
      return weekday >= 1 && weekday <= 6;
    }
    if (RegExp(r'seg.{0,4}dom').hasMatch(s)) {
      return true;
    }
    // Dias específicos isolados
    final dayMap = {
      'seg': 1, 'ter': 2, 'qua': 3, 'qui': 4,
      'sex': 5, 'sab': 6, 'dom': 7,
    };
    for (final entry in dayMap.entries) {
      if (s.contains(entry.key) && weekday == entry.value) return true;
    }
    // Se não especifica dia, assume seg-sex
    if (!RegExp(r'seg|ter|qua|qui|sex|sab|dom').hasMatch(s)) {
      return weekday >= 1 && weekday <= 5;
    }
    return false;
  }

  List<_TimeInterval> _extractTimeIntervals(String s) {
    final intervals = <_TimeInterval>[];
    // Captura padrões "HH:MM-HH:MM" ou "HH:MMhHH:MM"
    final pattern = RegExp(r'(\d{1,2}):(\d{2})\s*[-as]+\s*(\d{1,2}):(\d{2})');
    for (final match in pattern.allMatches(s)) {
      final startH = int.parse(match.group(1)!);
      final startM = int.parse(match.group(2)!);
      final endH = int.parse(match.group(3)!);
      final endM = int.parse(match.group(4)!);
      intervals.add(_TimeInterval(
        start: startH * 60 + startM,
        end: endH * 60 + endM,
      ));
    }
    return intervals;
  }

  String _formatMinutes(int total) {
    final h = (total ~/ 60).toString().padLeft(2, '0');
    final m = (total % 60).toString().padLeft(2, '0');
    return '${h}h${m == "00" ? "" : m}';
  }
}

class _TimeInterval {
  final int start, end;
  const _TimeInterval({required this.start, required this.end});
}
