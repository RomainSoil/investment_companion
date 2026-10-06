import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:investment_companion/data/app_preferences.dart';
import 'package:investment_companion/domain/price_history.dart';
import 'package:investment_companion/domain/savings_simulation.dart';
import 'package:investment_companion/features/assets/what_if_section.dart';
import 'package:investment_companion/state/settings_controller.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:investment_companion/features/calculator/compound_interest_screen.dart';

/// Affiche [child] sur un écran de téléphone de 390 x 844 points, avec les
/// réglages par défaut (montants en euros).
Future<void> pumpScreen(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({});
  final preferences = AppPreferences(await SharedPreferences.getInstance());

  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => SettingsController(preferences),
      child: MaterialApp(home: Scaffold(body: child)),
    ),
  );
}

void main() {
  testWidgets('le calculateur se met à jour à chaque saisie', (tester) async {
    await pumpScreen(tester, const CompoundInterestScreen());

    // Sans rendement, la valeur finale est la somme versée :
    // 1 000 € + 100 € x 12 mois x 10 ans.
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Rendement annuel espéré'),
      '0',
    );
    await tester.pump();

    expect(find.text('13\u00A0000,00\u00A0€'), findsOneWidget);
    expect(find.textContaining('13\u00A0000,00\u00A0€ (100\u00A0%)'),
        findsOneWidget);
  });

  testWidgets('« Et si j’avais investi » rejoue le placement sur l’historique',
      (tester) async {
    final history = PriceHistory(
      symbol: 'TEST',
      currency: 'USD',
      exchange: 'TEST',
      fetchedAt: DateTime(2026),
      points: [
        for (var i = 0; i <= 3 * 365; i++)
          PricePoint(
            date: DateTime(2023, 1, 1 + i),
            open: 100,
            high: 100,
            low: 100,
            close: 100.0 + i,
          ),
      ],
    );

    await pumpScreen(
      tester,
      SingleChildScrollView(
        child: WhatIfSection(
          assetName: 'Test',
          history: history,
          plan: const SavingsPlan(),
          onPlanChanged: (_) {},
        ),
      ),
    );

    expect(find.textContaining('Et si j’avais investi'), findsOneWidget);
    // La durée est ramenée aux 2 années complètes de l'historique.
    expect(find.text('Durée : 2 ans'), findsOneWidget);
    expect(find.text('Rendement annuel espéré'), findsNothing);
    expect(find.text('Valeur finale'), findsOneWidget);
  });
}
