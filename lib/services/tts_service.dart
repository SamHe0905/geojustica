// ignore: avoid_web_libraries_in_flutter
import 'dart:js_util' as js_util;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Text-to-Speech via SpeechSynthesis (Web Speech API)
class TtsService {
  bool get isSupported {
    try {
      return js_util.hasProperty(html.window, 'speechSynthesis');
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
      final synthesis = js_util.getProperty(html.window, 'speechSynthesis');
      final ctor = js_util.getProperty(html.window, 'SpeechSynthesisUtterance');
      final utterance = js_util.callConstructor(ctor, [text]);
      js_util.setProperty(utterance, 'lang', locale);
      js_util.setProperty(utterance, 'rate', rate);
      js_util.setProperty(utterance, 'onend',
          js_util.allowInterop((_) => _speaking = false));
      js_util.callMethod(synthesis, 'speak', [utterance]);
      _speaking = true;
    } catch (_) {}
  }

  void stop() {
    try {
      final synthesis = js_util.getProperty(html.window, 'speechSynthesis');
      js_util.callMethod(synthesis, 'cancel', []);
      _speaking = false;
    } catch (_) {}
  }
}
