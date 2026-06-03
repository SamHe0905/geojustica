import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InstallPopupNotifier extends StateNotifier<bool> {
  InstallPopupNotifier() : super(false);

  static const _key = 'install_popup_dismissed_at';

  /// Devolve true se deve mostrar o popup agora.
  Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    final dismissedAt = prefs.getInt(_key);
    if (dismissedAt == null) return true;
    // Mostra de novo após 14 dias
    final daysSince =
        (DateTime.now().millisecondsSinceEpoch - dismissedAt) / 86400000;
    return daysSince > 14;
  }

  Future<void> dismiss() async {
    (await SharedPreferences.getInstance())
        .setInt(_key, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> markInstalled() async {
    (await SharedPreferences.getInstance())
        .setInt(_key, DateTime.now().millisecondsSinceEpoch + 365 * 86400000);
  }
}

final installPopupProvider =
    StateNotifierProvider<InstallPopupNotifier, bool>(
        (_) => InstallPopupNotifier());
