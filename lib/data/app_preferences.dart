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
