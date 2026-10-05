import 'package:shared_preferences/shared_preferences.dart';

import '../domain/investor_profile.dart';

/// Petites données de l'utilisateur conservées sur le téléphone.
///
/// C'est la seule classe qui connaît `shared_preferences` et le nom des clés :
/// le reste de l'application passe par elle.
class AppPreferences {
  AppPreferences(this._store);

  final SharedPreferences _store;

  static const String welcomeSeenKey = 'welcome_seen';
  static const String profileTypeKey = 'profile_type';

  /// Vrai dès que l'utilisateur a quitté l'écran de bienvenue.
  bool get welcomeSeen => _store.getBool(welcomeSeenKey) ?? false;

  Future<void> setWelcomeSeen(bool value) async {
    await _store.setBool(welcomeSeenKey, value);
  }

  /// Profil investisseur enregistré, ou `null` s'il n'est pas encore défini.
  InvestorProfileType? get profileType {
    return InvestorProfileType.fromStorage(_store.getString(profileTypeKey));
  }

  Future<void> setProfileType(InvestorProfileType? type) async {
    if (type == null) {
      await _store.remove(profileTypeKey);
    } else {
      await _store.setString(profileTypeKey, type.name);
    }
  }
}
