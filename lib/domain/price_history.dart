import 'dart:math' as math;

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

  /// Volatilité annuelle (0,2 pour 20 %) : écart-type des variations d'une
  /// séance à l'autre, ramené à une année. Plus elle est forte, plus le cours
  /// varie et plus l'actif est risqué.
  double get annualVolatility {
    if (points.length < 3) {
      return 0;
    }

    final changes = [
      for (var i = 1; i < points.length; i++)
        points[i].close / points[i - 1].close - 1,
    ];
    final mean = changes.reduce((a, b) => a + b) / changes.length;
    final variance = changes
            .map((change) => (change - mean) * (change - mean))
            .reduce((a, b) => a + b) /
        (changes.length - 1);

    // Séances par an : environ 252 en bourse, 365 pour une cryptomonnaie.
    final days = points.last.date.difference(points.first.date).inDays;
    final sessionsPerYear = changes.length / days * 365.25;

    return math.sqrt(variance * sessionsPerYear);
  }
}
