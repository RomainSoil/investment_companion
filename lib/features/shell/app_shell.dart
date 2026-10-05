import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../state/navigation_controller.dart';
import '../home/home_screen.dart';
import 'coming_soon_screen.dart';
import 'profile_tab.dart';

/// Structure de l'application une fois l'écran de bienvenue passé : un écran
/// par onglet et la barre de navigation en bas.
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final navigation = context.watch<NavigationController>();

    return Scaffold(
      // IndexedStack garde les cinq écrans en mémoire et n'affiche que celui
      // de l'onglet courant : on retrouve chaque onglet tel qu'on l'a laissé.
      // L'ordre des écrans suit celui de l'énumération AppTab.
      body: IndexedStack(
        index: navigation.current.index,
        children: const [
          HomeScreen(),
          ComingSoonScreen(
            icon: Icons.calculate_outlined,
            title: 'Calculer',
            message:
                'Le calculateur d’intérêts composés et la simulation sur ETF '
                'ou action arrivent à la prochaine étape du développement.',
          ),
          ComingSoonScreen(
            icon: Icons.menu_book_outlined,
            title: 'Apprendre',
            message:
                'Les leçons (ETF ou action, PEA, PEL, compte-titres…) arrivent '
                'à une prochaine étape du développement.',
          ),
          ComingSoonScreen(
            icon: Icons.bookmark_border,
            title: 'Mes simulations',
            message:
                'Vos simulations enregistrées apparaîtront ici, y compris '
                'hors connexion.',
          ),
          ProfileTab(),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        // Filet de séparation dessiné par-dessus le haut de la barre.
        position: DecorationPosition.foreground,
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: NavigationBar(
          selectedIndex: navigation.current.index,
          onDestinationSelected: (index) {
            navigation.goTo(AppTab.values[index]);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Accueil',
            ),
            NavigationDestination(
              icon: Icon(Icons.calculate_outlined),
              selectedIcon: Icon(Icons.calculate),
              label: 'Calculer',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: 'Apprendre',
            ),
            NavigationDestination(
              icon: Icon(Icons.bookmark_border),
              selectedIcon: Icon(Icons.bookmark),
              label: 'Simulations',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
