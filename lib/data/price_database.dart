import '../domain/price_history.dart';
import 'app_database.dart';

/// Historiques de cours déjà téléchargés, dans les tables `price_series` et
/// `price_points` (voir [AppDatabase]).
class PriceDatabase {
  PriceDatabase(this._appDatabase);

  final AppDatabase _appDatabase;

  /// Historique enregistré de [symbol], ou `null` s'il n'a jamais été
  /// téléchargé.
  Future<PriceHistory?> load(String symbol) async {
    final db = await _appDatabase.database;

    final series = await db.query(
      'price_series',
      where: 'symbol = ?',
      whereArgs: [symbol],
    );
    if (series.isEmpty) {
      return null;
    }

    final rows = await db.query(
      'price_points',
      where: 'symbol = ?',
      whereArgs: [symbol],
      orderBy: 'date',
    );

    return PriceHistory(
      symbol: symbol,
      currency: series.first['currency'] as String,
      exchange: series.first['exchange'] as String,
      fetchedAt: DateTime.parse(series.first['fetched_at'] as String),
      points: [
        for (final row in rows)
          PricePoint(
            date: DateTime.parse(row['date'] as String),
            open: (row['open'] as num).toDouble(),
            high: (row['high'] as num).toDouble(),
            low: (row['low'] as num).toDouble(),
            close: (row['close'] as num).toDouble(),
            volume: (row['volume'] as num?)?.toDouble(),
          ),
      ],
    );
  }

  /// Enregistre [history], en remplaçant l'éventuel historique précédent du
  /// même actif.
  Future<void> save(PriceHistory history) async {
    final db = await _appDatabase.database;

    // Transaction : en cas d'échec, la base ne garde pas un historique à
    // moitié écrit.
    await db.transaction((txn) async {
      // La suppression efface aussi les cours (ON DELETE CASCADE).
      await txn.delete(
        'price_series',
        where: 'symbol = ?',
        whereArgs: [history.symbol],
      );
      await txn.insert('price_series', {
        'symbol': history.symbol,
        'currency': history.currency,
        'exchange': history.exchange,
        'fetched_at': history.fetchedAt.toIso8601String(),
      });

      final batch = txn.batch();
      for (final point in history.points) {
        batch.insert('price_points', {
          'symbol': history.symbol,
          'date': point.date.toIso8601String().substring(0, 10),
          'open': point.open,
          'high': point.high,
          'low': point.low,
          'close': point.close,
          'volume': point.volume,
        });
      }
      await batch.commit(noResult: true);
    });
  }
}
