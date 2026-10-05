import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:investment_companion/app.dart';
import 'package:investment_companion/data/app_preferences.dart';
import 'package:investment_companion/data/connectivity_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/fakes.dart';

/// Lance l'application sur un écran de téléphone, avec un stockage et un
/// réseau factices.
Future<void> pumpApp(
  WidgetTester tester, {
  Map<String, Object> stored = const {},
  ConnectivityService? connectivityService,
}) async {
  // Écran de 390 x 844 points, comme un téléphone courant.
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues(stored);
  final store = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    InvestmentCompanionApp(
      preferences: AppPreferences(store),
      connectivityService: connectivityService ?? FakeConnectivityService(),
    ),
  );
  await tester.pumpAndSettle();
}

/// Appuie sur un onglet de la barre de navigation.
Future<void> tapTab(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text(label),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  const alreadyWelcomed = <String, Object>{AppPreferences.welcomeSeenKey: true};

  group('Écran de bienvenue', () {
    testWidgets('s’affiche au premier lancement', (tester) async {
      await pumpApp(tester);

      expect(find.text('Investir, pas à pas.'), findsOneWidget);
      expect(find.text('Définir mon profil'), findsOneWidget);
      expect(find.text('Explorer sans profil'), findsOneWidget);
    });

    testWidgets('« Explorer sans profil » ouvre l’accueil et s’en souvient',
        (tester) async {
      await pumpApp(tester);

      await tester.tap(find.text('Explorer sans profil'));
      await tester.pumpAndSettle();

      expect(find.text('Investir, pas à pas.'), findsNothing);
      expect(find.text('Intérêts composés'), findsOneWidget);

      final store = await SharedPreferences.getInstance();
      expect(store.getBool(AppPreferences.welcomeSeenKey), isTrue);
    });

    testWidgets('« Définir mon profil » ouvre l’onglet Profil',
        (tester) async {
      await pumpApp(tester);

      await tester.tap(find.text('Définir mon profil'));
      await tester.pumpAndSettle();

      expect(find.text('Votre profil'), findsOneWidget);
      expect(find.text('Intérêts composés'), findsNothing);
    });

    testWidgets('ne s’affiche plus aux lancements suivants', (tester) async {
      await pumpApp(tester, stored: alreadyWelcomed);

      expect(find.text('Investir, pas à pas.'), findsNothing);
      expect(find.text('Intérêts composés'), findsOneWidget);
    });

    testWidgets('peut être revu depuis l’onglet Profil', (tester) async {
      await pumpApp(tester, stored: alreadyWelcomed);

      await tapTab(tester, 'Profil');
      await tester.tap(find.textContaining('Revoir'));
      await tester.pumpAndSettle();

      expect(find.text('Investir, pas à pas.'), findsOneWidget);
    });
  });

  group('Accueil', () {
    testWidgets('invite à définir le profil tant qu’il n’existe pas',
        (tester) async {
      await pumpApp(tester, stored: alreadyWelcomed);

      expect(find.text('Définir mon profil'), findsOneWidget);
    });

    testWidgets('affiche le profil enregistré', (tester) async {
      await pumpApp(
        tester,
        stored: const {
          AppPreferences.welcomeSeenKey: true,
          AppPreferences.profileTypeKey: 'equilibre',
        },
      );

      expect(find.text('Équilibré'), findsOneWidget);
      expect(find.text('Définir mon profil'), findsNothing);
    });

    testWidgets('en ligne, n’affiche pas le bandeau hors connexion',
        (tester) async {
      await pumpApp(tester, stored: alreadyWelcomed);

      expect(find.textContaining('vérifié à'), findsOneWidget);
      expect(find.text('Réessayer'), findsNothing);
    });

    testWidgets('hors connexion, « Réessayer » relance la vérification',
        (tester) async {
      final service = FakeConnectivityService(online: false);
      await pumpApp(
        tester,
        stored: alreadyWelcomed,
        connectivityService: service,
      );

      expect(find.textContaining('Hors connexion'), findsWidgets);
      expect(find.text('Réessayer'), findsOneWidget);

      // Le réseau revient, puis l'utilisateur réessaie.
      service.online = true;
      await tester.tap(find.text('Réessayer'));
      await tester.pumpAndSettle();

      expect(service.calls, 2);
      expect(find.text('Réessayer'), findsNothing);
    });

    testWidgets('une tuile mène à son onglet', (tester) async {
      await pumpApp(tester, stored: alreadyWelcomed);

      final tile = find.text('Intérêts composés');
      await tester.ensureVisible(tile);
      await tester.pumpAndSettle();
      await tester.tap(tile);
      await tester.pumpAndSettle();

      expect(find.textContaining('Le calculateur'), findsOneWidget);
    });
  });

  group('Barre de navigation', () {
    testWidgets('change d’onglet', (tester) async {
      await pumpApp(tester, stored: alreadyWelcomed);

      await tapTab(tester, 'Apprendre');

      expect(find.textContaining('Les leçons'), findsOneWidget);
      expect(find.text('Intérêts composés'), findsNothing);
    });
  });
}
