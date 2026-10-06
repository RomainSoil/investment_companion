import 'package:flutter_test/flutter_test.dart';
import 'package:investment_companion/data/app_preferences.dart';
import 'package:investment_companion/domain/currency.dart';
import 'package:investment_companion/state/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<AppPreferences> emptyPreferences() async {
    SharedPreferences.setMockInitialValues({});
    return AppPreferences(await SharedPreferences.getInstance());
  }

  test('affiche en euros avec le taux par défaut au premier lancement',
      () async {
    final controller = SettingsController(await emptyPreferences());

    expect(controller.currency.display, Currency.eur);
    expect(controller.currency.usdToEur, CurrencySettings.defaultUsdToEur);
  });

  test('enregistre la devise et le taux sur le téléphone', () async {
    final preferences = await emptyPreferences();
    final controller = SettingsController(preferences);

    await controller.setDisplayCurrency(Currency.usd);
    await controller.setUsdToEur(0.9);

    // Un nouveau contrôleur, comme après un redémarrage, relit les réglages.
    final restarted = SettingsController(preferences);
    expect(restarted.currency.display, Currency.usd);
    expect(restarted.currency.usdToEur, 0.9);
  });

  test('ignore un taux nul', () async {
    final controller = SettingsController(await emptyPreferences());

    await controller.setUsdToEur(0);

    expect(controller.currency.usdToEur, CurrencySettings.defaultUsdToEur);
  });

  test('convertit les dollars dans la devise d’affichage', () {
    const inEuros = CurrencySettings(usdToEur: 0.8);
    const inDollars = CurrencySettings(display: Currency.usd, usdToEur: 0.8);

    expect(inEuros.convert(100, Currency.usd), closeTo(80, 1e-9));
    expect(inDollars.convert(100, Currency.usd), 100);
    expect(inDollars.convert(80, Currency.eur), closeTo(100, 1e-9));
    expect(Currency.fromCode('US Dollar'), Currency.usd);
    expect(Currency.fromCode('GBP'), isNull);
  });
}
