import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../state/navigation_controller.dart';
import '../calculator/compound_interest_screen.dart';
import '../home/home_screen.dart';
import '../learn/learn_screen.dart';
import '../profile/profile_screen.dart';
import '../saved_simulations/saved_simulations_screen.dart';

/// Structure de l'application une fois l'écran de bienvenue passé : un écran
/// par onglet et la barre de navigation en bas.
///
/// Écrans et boutons de la barre sont construits à partir de [AppTab] : ils
/// sont toujours dans le même ordre. Pour ajouter un onglet, on l'ajoute à
/// l'énumération puis aux deux `switch` ci-dessous (le compilateur signale
/// tout oubli).
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final current = context.select<NavigationController, AppTab>(
      (navigation) => navigation.current,
    );

    return Scaffold(
      // IndexedStack garde tous les écrans en mémoire et n'affiche que celui
      // de l'onglet courant : on retrouve chaque onglet tel qu'on l'a laissé.
      body: IndexedStack(
        index: current.index,
        children: [for (final tab in AppTab.values) _screenFor(tab)],
      ),
      bottomNavigationBar: DecoratedBox(
        // Filet de séparation dessiné par-dessus le haut de la barre.
        position: DecorationPosition.foreground,
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: NavigationBar(
          selectedIndex: current.index,
          onDestinationSelected: (index) =>
              context.read<NavigationController>().goTo(AppTab.values[index]),
          destinations: [
            for (final tab in AppTab.values) _destinationFor(tab),
          ],
        ),
      ),
    );
  }
}

/// Écran affiché pour [tab].
Widget _screenFor(AppTab tab) {
  return switch (tab) {
    AppTab.home => const HomeScreen(),
    AppTab.calculator => const CompoundInterestScreen(),
    AppTab.learn => const LearnScreen(),
    AppTab.simulations => const SavedSimulationsScreen(),
    AppTab.profile => const ProfileScreen(),
  };
}

/// Bouton de [tab] dans la barre de navigation.
NavigationDestination _destinationFor(AppTab tab) {
  final (icon, selectedIcon, label) = switch (tab) {
    AppTab.home => (Icons.home_outlined, Icons.home, 'Accueil'),
    AppTab.calculator => (
        Icons.calculate_outlined,
        Icons.calculate,
        'Calculer'
      ),
    AppTab.learn => (Icons.menu_book_outlined, Icons.menu_book, 'Apprendre'),
    AppTab.simulations => (
        Icons.bookmark_border,
        Icons.bookmark,
        'Simulations'
      ),
    AppTab.profile => (Icons.person_outline, Icons.person, 'Profil'),
  };

  return NavigationDestination(
    icon: Icon(icon),
    selectedIcon: Icon(selectedIcon),
    label: label,
  );
}
