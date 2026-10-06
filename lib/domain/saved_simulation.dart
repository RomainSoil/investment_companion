import 'savings_simulation.dart';

/// Une simulation enregistrée par l'utilisateur, affichée dans « Mes
/// simulations ».
class SavedSimulation {
  const SavedSimulation({
    this.id,
    required this.createdAt,
    this.assetSymbol,
    this.assetName,
    required this.currency,
    required this.plan,
    required this.invested,
    required this.finalValue,
  });

  /// Identifiant en base, `null` tant que la simulation n'est pas enregistrée.
  final int? id;

  final DateTime createdAt;

  /// Actif de la simulation « Et si j'avais investi ? », `null` pour une
  /// simulation d'intérêts composés.
  final String? assetSymbol;
  final String? assetName;

  /// Symbole de la devise des montants, par exemple « € ».
  final String currency;

  /// Paramètres saisis. Pour une simulation sur un actif, `annualRate` est
  /// le rendement annuel moyen réel de l'actif sur la période.
  final SavingsPlan plan;

  /// Total versé à la fin du placement.
  final double invested;

  /// Valeur du placement à la fin.
  final double finalValue;

  bool get isHistorical => assetSymbol != null;

  /// Gains (ou pertes, si négatif).
  double get gains => finalValue - invested;
}
