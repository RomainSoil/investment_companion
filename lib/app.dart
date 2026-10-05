import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/app_preferences.dart';
import 'data/connectivity_service.dart';
import 'features/shell/app_shell.dart';
import 'features/welcome/welcome_screen.dart';
import 'state/app_controller.dart';
import 'state/connectivity_controller.dart';
import 'state/navigation_controller.dart';

/// Racine de l'application.
///
/// Les contrôleurs (l'état partagé) sont créés ici, au-dessus de tous les
/// écrans : n'importe quel écran peut les lire, et ils ne sont pas recréés
/// quand un écran est reconstruit.
///
/// Les accès au téléphone et au réseau sont reçus en paramètres : les tests
/// peuvent ainsi fournir des versions factices.
class InvestmentCompanionApp extends StatelessWidget {
  const InvestmentCompanionApp({
    super.key,
    required this.preferences,
    required this.connectivityService,
  });

  final AppPreferences preferences;
  final ConnectivityService connectivityService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppController>(
          create: (_) => AppController(preferences),
        ),
        ChangeNotifierProvider<NavigationController>(
          create: (_) => NavigationController(),
        ),
        ChangeNotifierProvider<ConnectivityController>(
          // Créé tout de suite pour lancer la première vérification dès le
          // démarrage, sans attendre qu'un écran en ait besoin.
          lazy: false,
          create: (_) => ConnectivityController(connectivityService)..check(),
        ),
      ],
      child: MaterialApp(
        title: 'Investment Companion',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        locale: const Locale('fr', 'FR'),
        supportedLocales: const [Locale('fr', 'FR')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: const AppRoot(),
      ),
    );
  }
}

/// Choisit l'écran à afficher selon l'étape de l'application.
class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final stage = context.select<AppController, AppStage>((app) => app.stage);

    // Fondu entre l'écran de bienvenue et l'application.
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: switch (stage) {
        AppStage.welcome => const WelcomeScreen(key: ValueKey('welcome')),
        AppStage.ready => const AppShell(key: ValueKey('shell')),
      },
    );
  }
}
