import 'asset.dart';

/// Les trois profils d'investisseur attribués par le questionnaire.
enum InvestorProfileType {
  prudent(
    'Prudent',
    RiskLevel.low,
    'Vous privilégiez la sécurité de votre épargne : des placements dont la '
        'valeur varie peu, quitte à gagner moins.',
  ),
  equilibre(
    'Équilibré',
    RiskLevel.medium,
    'Vous acceptez des variations raisonnables pour faire croître votre '
        'épargne, en restant diversifié.',
  ),
  dynamique(
    'Dynamique',
    RiskLevel.high,
    'Vous visez une croissance forte sur le long terme et acceptez de fortes '
        'baisses passagères. Gardez une base d’ETF larges pour rester '
        'diversifié.',
  );

  const InvestorProfileType(this.label, this.advisedRisk, this.description);

  /// Nom affiché à l'utilisateur.
  final String label;

  /// Niveau de risque des actifs conseillés à ce profil.
  final RiskLevel advisedRisk;

  /// Ce que le profil signifie, en une ou deux phrases.
  final String description;

  /// Actifs du catalogue conseillés à ce profil.
  List<Asset> get advisedAssets {
    return [
      for (final asset in assetCatalog)
        if (asset.risk == advisedRisk) asset,
    ];
  }

  /// Retrouve un profil à partir de la valeur enregistrée sur le téléphone
  /// (le `name` de l'énumération). Renvoie `null` si la valeur est absente
  /// ou inconnue.
  static InvestorProfileType? fromStorage(String? value) {
    for (final type in InvestorProfileType.values) {
      if (type.name == value) {
        return type;
      }
    }
    return null;
  }
}
