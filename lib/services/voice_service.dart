import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js_util' as js_util;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Reconhecimento de voz usando Web Speech API (Chrome/Edge).
class VoiceService {
  bool get isSupported {
    try {
      return js_util.hasProperty(html.window, 'webkitSpeechRecognition') ||
          js_util.hasProperty(html.window, 'SpeechRecognition');
    } catch (_) {
      return false;
    }
  }

  StreamController<String>? _controller;
  dynamic _recognition;

  Stream<String> listen({String locale = 'pt-BR'}) {
    _controller = StreamController<String>();
    try {
      final ctor = js_util.hasProperty(html.window, 'webkitSpeechRecognition')
          ? js_util.getProperty(html.window, 'webkitSpeechRecognition')
          : js_util.getProperty(html.window, 'SpeechRecognition');

      _recognition = js_util.callConstructor(ctor, []);
      js_util.setProperty(_recognition, 'lang', locale);
      js_util.setProperty(_recognition, 'continuous', false);
      js_util.setProperty(_recognition, 'interimResults', true);

      js_util.setProperty(
        _recognition,
        'onresult',
        js_util.allowInterop((event) {
          try {
            final results = js_util.getProperty(event, 'results');
            final length = js_util.getProperty(results, 'length') as int;
            final buffer = StringBuffer();
            for (var i = 0; i < length; i++) {
              final r = js_util.getProperty(results, i);
              final r0 = js_util.getProperty(r, 0);
              final t = js_util.getProperty(r0, 'transcript') as String;
              buffer.write(t);
            }
            _controller?.add(buffer.toString());
          } catch (_) {}
        }),
      );

      js_util.setProperty(
        _recognition,
        'onerror',
        js_util.allowInterop((event) {
          _controller?.addError('Erro no reconhecimento de voz');
          _controller?.close();
        }),
      );

      js_util.setProperty(
        _recognition,
        'onend',
        js_util.allowInterop(() => _controller?.close()),
      );

      js_util.callMethod(_recognition, 'start', []);
    } catch (e) {
      _controller?.addError('Reconhecimento de voz indisponível');
      _controller?.close();
    }
    return _controller!.stream;
  }

  void stop() {
    try {
      if (_recognition != null) {
        js_util.callMethod(_recognition, 'stop', []);
      }
    } catch (_) {}
    _controller?.close();
  }
}
