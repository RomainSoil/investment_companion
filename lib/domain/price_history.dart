/// Cours d'un actif sur une journée de cotation.
class PricePoint {
  const PricePoint({
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    this.volume,
  });

  final DateTime date;
  final double open;
  final double high;
  final double low;
  final double close;

  /// Volume échangé, absent pour certains actifs (devises par exemple).
  final double? volume;
}

/// Historique quotidien des cours d'un actif, du plus ancien au plus récent.
class PriceHistory {
  const PriceHistory({
    required this.symbol,
    required this.currency,
    required this.exchange,
    required this.fetchedAt,
    required this.points,
  });

  final String symbol;

  /// Devise des cours, par exemple « USD ».
  final String currency;

  /// Place de cotation, par exemple « NASDAQ ».
  final String exchange;

  /// Date du téléchargement depuis l'API.
  final DateTime fetchedAt;

  final List<PricePoint> points;
}
