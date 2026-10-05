import 'package:flutter/foundation.dart';

import '../data/app_preferences.dart';
import '../domain/investor_profile.dart';

/// Étape dans laquelle se trouve l'application.
enum AppStage {
  /// Premier lancement : on affiche l'écran de bienvenue.
  welcome,

  /// L'utilisateur est entré dans l'application.
  ready,
}

/// État partagé par toute l'application : étape en cours et profil
/// investisseur.
///
/// Cet état est placé au-dessus des écrans (voir `app.dart`) et enregistré sur
/// le téléphone : il survit à la reconstruction des widgets et au redémarrage
/// de l'application.
class AppController extends ChangeNotifier {
  AppController(this._preferences)
      : _stage =
            _preferences.welcomeSeen ? AppStage.ready : AppStage.welcome,
        _profile = _preferences.profileType;

  final AppPreferences _preferences;

  AppStage _stage;
  InvestorProfileType? _profile;

  AppStage get stage => _stage;

  /// Profil investisseur, ou `null` tant qu'il n'est pas défini.
  InvestorProfileType? get profile => _profile;

  bool get hasProfile => _profile != null;

  /// L'utilisateur quitte l'écran de bienvenue.
  ///
  /// On met d'abord l'écran à jour, puis on enregistre : l'interface ne reste
  /// pas bloquée pendant l'écriture sur le téléphone.
  Future<void> completeWelcome() async {
    if (_stage == AppStage.ready) {
      return;
    }
    _stage = AppStage.ready;
    notifyListeners();
    await _preferences.setWelcomeSeen(true);
  }

  /// Réaffiche l'écran de bienvenue (pratique pour une démonstration).
  Future<void> showWelcomeAgain() async {
    if (_stage == AppStage.welcome) {
      return;
    }
    _stage = AppStage.welcome;
    notifyListeners();
    await _preferences.setWelcomeSeen(false);
  }

  /// Enregistre le profil investisseur. `null` efface le profil.
  Future<void> setProfile(InvestorProfileType? profile) async {
    if (profile == _profile) {
      return;
    }
    _profile = profile;
    notifyListeners();
    await _preferences.setProfileType(profile);
  }
}
