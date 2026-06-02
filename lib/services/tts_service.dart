// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

/// Text-to-Speech via SpeechSynthesis (Web Speech API)
class TtsService {
  bool get isSupported {
    try {
      return html.window.speechSynthesis != null;
    } catch (_) {
      return false;
    }
  }

  bool _speaking = false;
  bool get speaking => _speaking;

  void speak(String text, {String locale = 'pt-BR', double rate = 0.95}) {
    try {
      if (!isSupported) return;
      stop();
      final synthesis = html.window.speechSynthesis;
      if (synthesis == null) return;
      final utterance = html.SpeechSynthesisUtterance(text)
        ..lang = locale
        ..rate = rate
        ..onEnd.listen((_) => _speaking = false);
      synthesis.speak(utterance);
      _speaking = true;
    } catch (_) {}
  }

  void stop() {
    try {
      html.window.speechSynthesis?.cancel();
      _speaking = false;
    } catch (_) {}
  }
}
