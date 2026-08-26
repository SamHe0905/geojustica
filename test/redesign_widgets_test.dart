import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geojustica/models/institution.dart';
import 'package:geojustica/core/constants/category_style.dart';
import 'package:geojustica/features/home/widgets/category_button.dart';
import 'package:geojustica/shared/widgets/accessibility_bar.dart';
import 'package:geojustica/shared/widgets/geo_icon.dart';

void main() {
  testWidgets('CategoryButton renderiza rótulo e ícone SVG sem estourar', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 120,
            height: 120,
            child: CategoryButton(
              category: InstitutionCategory.violenciaDomestica,
              onTap: () => tapped = true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Violência doméstica'), findsOneWidget);
    expect(find.byType(GeoIcon), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byType(CategoryButton));
    expect(tapped, isTrue);
  });

  testWidgets('todas as categorias têm nome de ícone e cor definidos', (tester) async {
    for (final cat in InstitutionCategory.values) {
      expect(cat.iconName, isNotEmpty);
      // color acessa sem lançar
      expect(cat.color, isA<Color>());
    }
  });

  testWidgets('AccessibilityBar mostra controles e responde ao toque', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: AccessibilityBar()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Texto'), findsOneWidget);
    expect(find.text('Contraste'), findsOneWidget);

    // Tocar em aumentar/contraste não deve lançar.
    await tester.tap(find.text('Contraste'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
