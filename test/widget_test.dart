import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:investment_companion/app.dart';
import 'package:investment_companion/data/app_database.dart';
import 'package:investment_companion/data/app_preferences.dart';
import 'package:investment_companion/data/connectivity_service.dart';
import 'package:investment_companion/data/price_database.dart';
import 'package:investment_companion/data/price_repository.dart';
import 'package:investment_companion/data/twelve_data_client.dart';
import 'package:investment_companion/domain/saved_simulation.dart';
import 'package:investment_companion/domain/savings_simulation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'helpers/fakes.dart';

/// Lance l'application sur un écran de téléphone, avec un stockage et un
/// réseau factices.
Future<void> pumpApp(
  WidgetTester tester, {
  Map<String, Object> stored = const {},
  ConnectivityService? connectivityService,
  PriceRepository? priceRepository,
  List<SavedSimulation> simulations = const [],
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
      // Par défaut, ni base ni réseau : la base n'est ouverte qu'au premier
      // actif affiché, et la clé vide empêche tout appel.
      priceRepository: priceRepository ??
          PriceRepository(
            database: PriceDatabase(AppDatabase(path: inMemoryDatabasePath)),
            client: TwelveDataClient(apiKey: ''),
          ),
      simulationDatabase: FakeSimulationDatabase(simulations),
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

/// Ouvre une leçon depuis la liste de l'onglet « Apprendre ».
Future<void> openLesson(WidgetTester tester, String title) async {
  final tile = find.text(title);
  await tester.ensureVisible(tile);
  await tester.pumpAndSettle();
  await tester.tap(tile);
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

    testWidgets('« Définir mon profil » ouvre l’onglet Profil', (tester) async {
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

      expect(find.text('Montant initial'), findsOneWidget);
    });

    testWidgets('« Simuler un ETF » ouvre la liste des actifs', (tester) async {
      await pumpApp(tester, stored: alreadyWelcomed);

      final tile = find.text('Simuler un ETF ou une action');
      await tester.ensureVisible(tile);
      await tester.pumpAndSettle();
      await tester.tap(tile);
      await tester.pumpAndSettle();

      expect(find.text('Choisir un actif'), findsOneWidget);
      expect(find.text('SPDR S&P 500'), findsOneWidget);
    });
  });

  group('Mes simulations', () {
    testWidgets('une simulation enregistrée s’affiche, puis se supprime',
        (tester) async {
      await pumpApp(tester, stored: alreadyWelcomed);

      await tapTab(tester, 'Simulations');
      expect(find.textContaining('Aucune simulation'), findsOneWidget);

      await tapTab(tester, 'Calculer');
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Montant initial'),
        '2500',
      );
      // Le bouton est en bas de la liste, construite au fil du défilement.
      final save = find.text('Enregistrer la simulation');
      await tester.scrollUntilVisible(
        save,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(find.text('Simulation enregistrée.'), findsOneWidget);

      await tapTab(tester, 'Simulations');
      expect(find.text('Intérêts composés'), findsOneWidget);
      expect(find.textContaining('Aucune simulation'), findsNothing);

      // La carte rouvre le calculateur, prérempli.
      await tester.tap(find.text('Intérêts composés'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextFormField, '2500'), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Supprimer'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Aucune simulation'), findsOneWidget);
    });
  });

  testWidgets('une simulation sur un actif rouvre sa fiche, préremplie',
      (tester) async {
    await pumpApp(
      tester,
      stored: alreadyWelcomed,
      priceRepository: FakePriceRepository(),
      simulations: [
        SavedSimulation(
          createdAt: DateTime(2026, 10, 6),
          assetSymbol: 'SPY',
          assetName: 'SPDR S&P 500',
          currency: '€',
          plan: const SavingsPlan(years: 2),
          invested: 3400,
          finalValue: 4000,
        ),
      ],
    );

    await tapTab(tester, 'Simulations');
    await tester.tap(find.textContaining('SPDR S&P 500'));
    await tester.pumpAndSettle();

    // Fiche de l'actif, déroulée jusqu'à la simulation et ses paramètres.
    expect(find.widgetWithText(AppBar, 'SPDR S&P 500'), findsOneWidget);
    expect(find.text('Durée : 2 ans').hitTestable(), findsOneWidget);
  });

  group('Barre de navigation', () {
    testWidgets('change d’onglet', (tester) async {
      await pumpApp(tester, stored: alreadyWelcomed);

      await tapTab(tester, 'Apprendre');

      expect(find.text('Votre parcours'), findsOneWidget);
      expect(find.text('Intérêts composés'), findsNothing);
    });
  });

  group('Leçons', () {
    testWidgets('la liste affiche les leçons et la progression',
        (tester) async {
      await pumpApp(tester, stored: alreadyWelcomed);

      await tapTab(tester, 'Apprendre');

      expect(find.text('0 / 7 leçons'), findsOneWidget);
      expect(find.text('Les intérêts composés'), findsOneWidget);
    });

    testWidgets('ouvrir une leçon la passe en cours', (tester) async {
      await pumpApp(tester, stored: alreadyWelcomed);
      await tapTab(tester, 'Apprendre');

      await openLesson(tester, 'Les intérêts composés');
      expect(find.text('Leçon'), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.text('En cours'), findsOneWidget);
    });

    testWidgets('répondre au quiz affiche l’explication', (tester) async {
      await pumpApp(tester, stored: alreadyWelcomed);
      await tapTab(tester, 'Apprendre');

      await openLesson(tester, 'Les intérêts composés');

      final answer = find.text('La durée du placement');
      await tester.scrollUntilVisible(
        answer,
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(answer);
      await tester.pumpAndSettle();

      expect(find.text('Bonne réponse.'), findsOneWidget);
    });

    testWidgets('terminer une leçon met à jour la progression',
        (tester) async {
      await pumpApp(tester, stored: alreadyWelcomed);
      await tapTab(tester, 'Apprendre');

      await openLesson(tester, 'Les intérêts composés');

      final finish = find.textContaining('terminé la leçon');
      await tester.scrollUntilVisible(
        finish,
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(finish);
      await tester.pumpAndSettle();

      expect(find.text('1 / 7 leçons'), findsOneWidget);

      final store = await SharedPreferences.getInstance();
      expect(
        store.getStringList(AppPreferences.lessonsDoneKey),
        ['interets-composes'],
      );
    });

    testWidgets('le filtre n’affiche que le thème choisi', (tester) async {
      await pumpApp(tester, stored: alreadyWelcomed);
      await tapTab(tester, 'Apprendre');

      await tester.tap(find.widgetWithText(ChoiceChip, 'Enveloppes'));
      await tester.pumpAndSettle();

      expect(find.text('PEA, PEL, compte-titres'), findsOneWidget);
      expect(find.text('Les intérêts composés'), findsNothing);
    });
  });
}
