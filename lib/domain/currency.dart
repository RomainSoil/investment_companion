/// Devises gérées par l'application.
enum Currency {
  eur('€'),
  usd('\$');

  const Currency(this.symbol);

  /// Symbole affiché après les montants.
  final String symbol;

  /// Devise correspondant au code renvoyé par l'API de cours (« USD », ou
  /// « US Dollar » pour les cryptomonnaies), `null` si elle n'est pas gérée.
  static Currency? fromCode(String code) {
    return switch (code) {
      'EUR' || 'Euro' => Currency.eur,
      'USD' || 'US Dollar' => Currency.usd,
      _ => null,
    };
  }
}

/// Réglages de devise choisis par l'utilisateur.
class CurrencySettings {
  const CurrencySettings({
    this.display = Currency.eur,
    this.usdToEur = defaultUsdToEur,
  });

  /// Taux proposé tant que l'utilisateur ne l'a pas modifié.
  static const double defaultUsdToEur = 0.86;

  /// Devise dans laquelle les montants sont affichés.
  final Currency display;

  /// Valeur d'un dollar en euros.
  final double usdToEur;

  /// Convertit [amount], exprimé en [from], dans la devise d'affichage.
  double convert(double amount, Currency from) {
    if (from == display) {
      return amount;
    }
    return display == Currency.eur ? amount * usdToEur : amount / usdToEur;
  }
}
