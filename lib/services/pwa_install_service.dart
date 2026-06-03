import 'dart:async';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

enum DevicePlatform { android, ios, desktop, unknown }

class PwaInstallService {
  PwaInstallService._() {
    _setup();
  }
  static final PwaInstallService instance = PwaInstallService._();

  bool _installed = false;
  bool _canInstall = false;
  final _ready = Completer<void>();

  void _setup() {
    try {
      // Detecta se já está instalado (standalone)
      final displayMode = html.window.matchMedia('(display-mode: standalone)');
      if (displayMode.matches == true) _installed = true;

      // Marca que o navegador suporta install (capturou beforeinstallprompt)
      html.window.addEventListener('beforeinstallprompt', (event) {
        _canInstall = true;
        try {
          event.preventDefault();
        } catch (_) {}
      });

      html.window.addEventListener('appinstalled', (_) {
        _installed = true;
      });
    } catch (_) {}

    Timer(const Duration(seconds: 2), () {
      if (!_ready.isCompleted) _ready.complete();
    });
  }

  Future<void> waitReady() => _ready.future;

  bool get isInstalled => _installed;
  bool get supportsInstall => _canInstall;

  DevicePlatform get platform {
    try {
      final ua = html.window.navigator.userAgent.toLowerCase();
      if (ua.contains('iphone') || ua.contains('ipad') || ua.contains('ipod')) {
        return DevicePlatform.ios;
      }
      if (ua.contains('android')) return DevicePlatform.android;
      if (ua.contains('mac') || ua.contains('win') || ua.contains('linux')) {
        return DevicePlatform.desktop;
      }
      return DevicePlatform.unknown;
    } catch (_) {
      return DevicePlatform.unknown;
    }
  }
}
