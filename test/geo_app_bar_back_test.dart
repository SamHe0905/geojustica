import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:geojustica/shared/widgets/geo_app_bar.dart';

/// Regressão do bug da "tela verde ao voltar": quando a página atual é a única
/// da pilha (ex.: chegou nela via context.go, que zera o histórico), tocar em
/// voltar deve levar para a home em vez de esvaziar o Navigator.
void main() {
  testWidgets('voltar sem histórico vai para a home em vez de esvaziar',
      (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(
            body: Center(child: Text('HOME')),
          ),
        ),
        GoRoute(
          path: '/resultados',
          builder: (_, __) => const Scaffold(
            appBar: GeoAppBar(title: 'Resultados'),
            body: Center(child: Text('RESULTADOS')),
          ),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    // Vai para /resultados com go(), que substitui a pilha inteira (sem voltar).
    router.go('/resultados');
    await tester.pumpAndSettle();
    expect(find.text('RESULTADOS'), findsOneWidget);

    // Toca no botão voltar do GeoAppBar.
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    // Deve ter caído na home — nunca numa tela vazia.
    expect(find.text('HOME'), findsOneWidget);
    expect(find.text('RESULTADOS'), findsNothing);
  });
}
