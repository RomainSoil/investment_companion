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

/// Un actif dont on peut télécharger l'historique des cours.
class Asset {
  const Asset(this.symbol, this.name, this.category, this.description);

  /// Symbole sur l'API Twelve Data, par exemple « SPY » ou « BTC/USD ».
  final String symbol;
  final String name;
  final AssetCategory category;

  /// Ce que représente l'actif, en quelques mots.
  final String description;
}

/// Actifs proposés, regroupés par famille.
///
/// L'offre gratuite de Twelve Data ne couvre que les places américaines : les
/// ETF ci-dessous sont des ETF cotés aux États-Unis, et les métaux sont suivis
/// au travers d'ETF adossés au métal physique.
const List<Asset> assetCatalog = [
  Asset('SPY', 'SPDR S&P 500', AssetCategory.etf,
      '500 grandes entreprises américaines'),
  Asset('QQQ', 'Invesco QQQ', AssetCategory.etf,
      '100 grandes valeurs du Nasdaq, surtout technologiques'),
  Asset('VTI', 'Vanguard Total Stock Market', AssetCategory.etf,
      'Toute la bourse américaine'),
  Asset('URTH', 'iShares MSCI World', AssetCategory.etf,
      'Grandes entreprises des pays développés'),
  Asset('VGK', 'Vanguard FTSE Europe', AssetCategory.etf,
      'Grandes entreprises européennes'),
  Asset('VWO', 'Vanguard FTSE Emerging Markets', AssetCategory.etf,
      'Entreprises des pays émergents'),
  Asset('SCHD', 'Schwab US Dividend Equity', AssetCategory.etf,
      'Entreprises américaines versant des dividendes'),
  Asset('VNQ', 'Vanguard Real Estate', AssetCategory.etf,
      'Immobilier coté américain'),
  Asset('AGG', 'iShares Core US Aggregate Bond', AssetCategory.etf,
      'Obligations américaines'),
  Asset('TLT', 'iShares 20+ Year Treasury Bond', AssetCategory.etf,
      'Emprunts d’État américains à long terme'),
  Asset('AAPL', 'Apple', AssetCategory.stock, 'Électronique et logiciels'),
  Asset('MSFT', 'Microsoft', AssetCategory.stock, 'Logiciels et cloud'),
  Asset('NVDA', 'Nvidia', AssetCategory.stock, 'Puces graphiques et IA'),
  Asset('AMZN', 'Amazon', AssetCategory.stock, 'Commerce en ligne et cloud'),
  Asset('GOOGL', 'Alphabet (Google)', AssetCategory.stock,
      'Recherche en ligne et publicité'),
  Asset('TSLA', 'Tesla', AssetCategory.stock, 'Voitures électriques'),
  Asset('KO', 'Coca-Cola', AssetCategory.stock, 'Boissons'),
  Asset('ASML', 'ASML', AssetCategory.stock,
      'Machines pour fabriquer des puces (Pays-Bas)'),
  Asset('TTE', 'TotalEnergies', AssetCategory.stock, 'Énergie (France)'),
  Asset('GLD', 'SPDR Gold Shares', AssetCategory.commodity, 'Or physique'),
  Asset('SLV', 'iShares Silver Trust', AssetCategory.commodity,
      'Argent physique'),
  Asset('PPLT', 'abrdn Platinum', AssetCategory.commodity, 'Platine physique'),
  Asset(
      'CPER', 'United States Copper Index', AssetCategory.commodity, 'Cuivre'),
  Asset(
      'USO', 'United States Oil Fund', AssetCategory.commodity, 'Pétrole brut'),
  Asset('BTC/USD', 'Bitcoin', AssetCategory.crypto,
      'Première cryptomonnaie, en dollars'),
];
