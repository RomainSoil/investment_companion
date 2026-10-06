import 'package:flutter/foundation.dart';

import '../data/app_preferences.dart';
import '../domain/currency.dart';

/// Réglages de l'utilisateur : devise d'affichage et taux de change.
///
/// Enregistrés sur le téléphone, ils survivent au redémarrage.
class SettingsController extends ChangeNotifier {
  SettingsController(this._preferences)
      : _currency = _preferences.currencySettings;

  final AppPreferences _preferences;

  CurrencySettings _currency;

  CurrencySettings get currency => _currency;

  Future<void> setDisplayCurrency(Currency display) {
    return _update(
      CurrencySettings(display: display, usdToEur: _currency.usdToEur),
    );
  }

  /// Change la valeur d'un dollar en euros. Un taux nul ou négatif est
  /// ignoré.
  Future<void> setUsdToEur(double rate) async {
    if (rate <= 0) {
      return;
    }
    await _update(CurrencySettings(display: _currency.display, usdToEur: rate));
  }

  /// Comme pour le profil : l'écran est mis à jour tout de suite, puis le
  /// réglage est enregistré.
  Future<void> _update(CurrencySettings settings) async {
    _currency = settings;
    notifyListeners();
    await _preferences.setCurrencySettings(settings);
  }
}
