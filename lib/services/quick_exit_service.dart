// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

/// Saída rápida para quem pode estar sendo vigiado.
///
/// Navega para um site neutro e **substitui** a entrada atual do histórico, de
/// modo que o botão "voltar" do navegador não retorne a esta página.
class QuickExitService {
  static void leave() {
    html.window.location.replace('https://www.google.com');
  }
}
