/// Familles d'actifs proposées à la simulation.
enum AssetCategory {
  etf('ETF'),
  stock('Actions'),
  commodity('Métaux et matières premières'),
  crypto('Cryptomonnaies');

  const AssetCategory(this.label);

  /// Nom affiché à l'utilisateur.
  final String label;
}

/// Niveau de risque d'un actif, d'après l'ampleur habituelle des variations
/// de son cours (sa volatilité annuelle).
enum RiskLevel {
  /// Moins de 17 % de volatilité environ : obligations, or, valeurs stables.
  low('Faible'),

  /// De 17 à 30 % environ : grands indices boursiers, grandes entreprises.
  medium('Modéré'),

  /// Plus de 30 % environ : valeurs de croissance, pétrole, cryptomonnaies.
  high('Élevé');

  const RiskLevel(this.label);

  /// Nom affiché à l'utilisateur.
  final String label;
}

/// Un actif dont on peut télécharger l'historique des cours.
class Asset {
  const Asset({
    required this.symbol,
    required this.name,
    required this.category,
    required this.risk,
    required this.description,
  });

  /// Symbole sur l'API Twelve Data, par exemple « SPY » ou « BTC/USD ».
  final String symbol;
  final String name;
  final AssetCategory category;
  final RiskLevel risk;

  /// Ce que représente l'actif, en quelques mots.
  final String description;
}

/// Actifs proposés, regroupés par famille.
///
/// L'offre gratuite de Twelve Data ne couvre que les places américaines : les
/// ETF ci-dessous sont des ETF cotés aux États-Unis, et les métaux sont suivis
/// au travers d'ETF adossés au métal physique.
///
/// Le niveau de risque est fixé d'après la volatilité habituelle de chaque
/// actif : le calculer depuis les cours demanderait de télécharger les 25
/// historiques. La fiche d'un actif affiche la volatilité réellement mesurée.
const List<Asset> assetCatalog = [
  // ETF
  Asset(
    symbol: 'SPY',
    name: 'SPDR S&P 500',
    category: AssetCategory.etf,
    risk: RiskLevel.medium,
    description: '500 grandes entreprises américaines',
  ),
  Asset(
    symbol: 'QQQ',
    name: 'Invesco QQQ',
    category: AssetCategory.etf,
    risk: RiskLevel.medium,
    description: '100 grandes valeurs du Nasdaq, surtout technologiques',
  ),
  Asset(
    symbol: 'VTI',
    name: 'Vanguard Total Stock Market',
    category: AssetCategory.etf,
    risk: RiskLevel.medium,
    description: 'Toute la bourse américaine',
  ),
  Asset(
    symbol: 'URTH',
    name: 'iShares MSCI World',
    category: AssetCategory.etf,
    risk: RiskLevel.medium,
    description: 'Grandes entreprises des pays développés',
  ),
  Asset(
    symbol: 'VGK',
    name: 'Vanguard FTSE Europe',
    category: AssetCategory.etf,
    risk: RiskLevel.medium,
    description: 'Grandes entreprises européennes',
  ),
  Asset(
    symbol: 'VWO',
    name: 'Vanguard FTSE Emerging Markets',
    category: AssetCategory.etf,
    risk: RiskLevel.medium,
    description: 'Entreprises des pays émergents',
  ),
  Asset(
    symbol: 'SCHD',
    name: 'Schwab US Dividend Equity',
    category: AssetCategory.etf,
    risk: RiskLevel.low,
    description: 'Entreprises américaines versant des dividendes',
  ),
  Asset(
    symbol: 'VNQ',
    name: 'Vanguard Real Estate',
    category: AssetCategory.etf,
    risk: RiskLevel.medium,
    description: 'Immobilier coté américain',
  ),
  Asset(
    symbol: 'AGG',
    name: 'iShares Core US Aggregate Bond',
    category: AssetCategory.etf,
    risk: RiskLevel.low,
    description: 'Obligations américaines',
  ),
  Asset(
    symbol: 'TLT',
    name: 'iShares 20+ Year Treasury Bond',
    category: AssetCategory.etf,
    risk: RiskLevel.medium,
    description: 'Emprunts d’État américains à long terme',
  ),

  // Actions
  Asset(
    symbol: 'AAPL',
    name: 'Apple',
    category: AssetCategory.stock,
    risk: RiskLevel.medium,
    description: 'Électronique et logiciels',
  ),
  Asset(
    symbol: 'MSFT',
    name: 'Microsoft',
    category: AssetCategory.stock,
    risk: RiskLevel.medium,
    description: 'Logiciels et cloud',
  ),
  Asset(
    symbol: 'NVDA',
    name: 'Nvidia',
    category: AssetCategory.stock,
    risk: RiskLevel.high,
    description: 'Puces graphiques et IA',
  ),
  Asset(
    symbol: 'AMZN',
    name: 'Amazon',
    category: AssetCategory.stock,
    risk: RiskLevel.high,
    description: 'Commerce en ligne et cloud',
  ),
  Asset(
    symbol: 'GOOGL',
    name: 'Alphabet (Google)',
    category: AssetCategory.stock,
    risk: RiskLevel.medium,
    description: 'Recherche en ligne et publicité',
  ),
  Asset(
    symbol: 'TSLA',
    name: 'Tesla',
    category: AssetCategory.stock,
    risk: RiskLevel.high,
    description: 'Voitures électriques',
  ),
  Asset(
    symbol: 'KO',
    name: 'Coca-Cola',
    category: AssetCategory.stock,
    risk: RiskLevel.low,
    description: 'Boissons',
  ),
  Asset(
    symbol: 'ASML',
    name: 'ASML',
    category: AssetCategory.stock,
    risk: RiskLevel.high,
    description: 'Machines pour fabriquer des puces (Pays-Bas)',
  ),
  Asset(
    symbol: 'TTE',
    name: 'TotalEnergies',
    category: AssetCategory.stock,
    risk: RiskLevel.medium,
    description: 'Énergie (France)',
  ),

  // Métaux et matières premières
  Asset(
    symbol: 'GLD',
    name: 'SPDR Gold Shares',
    category: AssetCategory.commodity,
    risk: RiskLevel.low,
    description: 'Or physique',
  ),
  Asset(
    symbol: 'SLV',
    name: 'iShares Silver Trust',
    category: AssetCategory.commodity,
    risk: RiskLevel.high,
    description: 'Argent physique',
  ),
  Asset(
    symbol: 'PPLT',
    name: 'abrdn Platinum',
    category: AssetCategory.commodity,
    risk: RiskLevel.medium,
    description: 'Platine physique',
  ),
  Asset(
    symbol: 'CPER',
    name: 'United States Copper Index',
    category: AssetCategory.commodity,
    risk: RiskLevel.medium,
    description: 'Cuivre',
  ),
  Asset(
    symbol: 'USO',
    name: 'United States Oil Fund',
    category: AssetCategory.commodity,
    risk: RiskLevel.high,
    description: 'Pétrole brut',
  ),

  // Cryptomonnaies
  Asset(
    symbol: 'BTC/USD',
    name: 'Bitcoin',
    category: AssetCategory.crypto,
    risk: RiskLevel.high,
    description: 'Première cryptomonnaie, en dollars',
  ),
];

/// Actif du catalogue portant ce [symbol], ou `null` s'il n'y figure plus.
Asset? assetBySymbol(String symbol) {
  for (final asset in assetCatalog) {
    if (asset.symbol == symbol) {
      return asset;
    }
  }
  return null;
}
