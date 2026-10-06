import 'package:shared_preferences/shared_preferences.dart';

import '../domain/currency.dart';
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
  static const String displayCurrencyKey = 'display_currency';
  static const String usdToEurKey = 'usd_to_eur';
  static const String lessonsStartedKey = 'lessons_started';
  static const String lessonsDoneKey = 'lessons_done';

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

  /// Identifiants des leçons ouvertes au moins une fois.
  Set<String> get lessonsStarted {
    return (_store.getStringList(lessonsStartedKey) ?? const []).toSet();
  }

  Future<void> setLessonsStarted(Set<String> ids) async {
    await _store.setStringList(lessonsStartedKey, ids.toList()..sort());
  }

  /// Identifiants des leçons terminées.
  Set<String> get lessonsDone {
    return (_store.getStringList(lessonsDoneKey) ?? const []).toSet();
  }

  Future<void> setLessonsDone(Set<String> ids) async {
    await _store.setStringList(lessonsDoneKey, ids.toList()..sort());
  }

  /// Devise d'affichage et taux de change, ou les valeurs par défaut s'ils
  /// n'ont jamais été modifiés.
  CurrencySettings get currencySettings {
    final display =
        Currency.values.asNameMap()[_store.getString(displayCurrencyKey)] ??
            Currency.eur;
    return CurrencySettings(
      display: display,
      usdToEur:
          _store.getDouble(usdToEurKey) ?? CurrencySettings.defaultUsdToEur,
    );
  }

  Future<void> setCurrencySettings(CurrencySettings settings) async {
    await _store.setString(displayCurrencyKey, settings.display.name);
    await _store.setDouble(usdToEurKey, settings.usdToEur);
  }
}
