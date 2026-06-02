import 'dart:async';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

/// Reconhecimento de voz via Web Speech API.
/// Implementação simplificada — usa apenas APIs estáveis do dart:html.
class VoiceService {
  bool _supported = false;
  bool get isSupported => _supported;

  VoiceService() {
    // Verifica se o navegador suporta SpeechRecognition (webkitSpeechRecognition)
    try {
      _supported = html.window.navigator.userAgent.toLowerCase().contains('chrome') ||
          html.window.navigator.userAgent.toLowerCase().contains('edge');
    } catch (_) {
      _supported = false;
    }
  }

  StreamController<String>? _controller;

  /// Retorna stream — vazio se navegador não suporta.
  Stream<String> listen({String locale = 'pt-BR'}) {
    _controller = StreamController<String>();
    // Implementação simplificada: avisa que não está disponível neste build.
    // Para implementação completa de voz, é necessário package:web + dart:js_interop.
    Future.microtask(() {
      _controller?.addError('Reconhecimento de voz não disponível neste build');
      _controller?.close();
    });
    return _controller!.stream;
  }

  void stop() {
    _controller?.close();
  }
}
