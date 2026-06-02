import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final double fontScale;
  final bool highContrast;
  final bool onboardingSeen;

  const AppSettings({
    this.fontScale = 1.0,
    this.highContrast = false,
    this.onboardingSeen = false,
  });

  AppSettings copyWith({double? fontScale, bool? highContrast, bool? onboardingSeen}) =>
      AppSettings(
        fontScale: fontScale ?? this.fontScale,
        highContrast: highContrast ?? this.highContrast,
        onboardingSeen: onboardingSeen ?? this.onboardingSeen,
      );
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) => SettingsNotifier());

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppSettings(
      fontScale: prefs.getDouble('fontScale') ?? 1.0,
      highContrast: prefs.getBool('highContrast') ?? false,
      onboardingSeen: prefs.getBool('onboardingSeen') ?? false,
    );
  }

  Future<void> setFontScale(double v) async {
    state = state.copyWith(fontScale: v);
    (await SharedPreferences.getInstance()).setDouble('fontScale', v);
  }

  Future<void> toggleHighContrast() async {
    state = state.copyWith(highContrast: !state.highContrast);
    (await SharedPreferences.getInstance())
        .setBool('highContrast', state.highContrast);
  }

  Future<void> markOnboardingSeen() async {
    state = state.copyWith(onboardingSeen: true);
    (await SharedPreferences.getInstance()).setBool('onboardingSeen', true);
  }

  void incrementFont() {
    final next = (state.fontScale + 0.15).clamp(0.85, 1.6);
    setFontScale(next);
  }

  void decrementFont() {
    final next = (state.fontScale - 0.15).clamp(0.85, 1.6);
    setFontScale(next);
  }
}
