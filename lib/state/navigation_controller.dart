import 'package:flutter/foundation.dart';

/// Les cinq onglets de la barre de navigation, dans leur ordre d'affichage.
enum AppTab { home, calculator, learn, simulations, profile }

/// Onglet affiché.
///
/// L'état est partagé : la barre de navigation le modifie, mais aussi les
/// tuiles de l'accueil et l'écran de bienvenue.
class NavigationController extends ChangeNotifier {
  AppTab _current = AppTab.home;

  AppTab get current => _current;

  void goTo(AppTab tab) {
    if (tab == _current) {
      return;
    }
    _current = tab;
    notifyListeners();
  }
}
