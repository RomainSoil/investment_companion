import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../domain/price_history.dart';

/// Base SQLite des historiques de cours déjà téléchargés.
///
/// C'est la seule classe qui connaît SQLite et le nom des tables. La base est
/// ouverte au premier accès, pas au démarrage de l'application.
///
/// Structure :
/// - `price_series` : une ligne par actif téléchargé (devise, place de
///   cotation, date du téléchargement) ;
/// - `price_points` : une ligne par actif et par jour de cotation.
class PriceDatabase {
  PriceDatabase({String? path}) : _path = path;

  /// Chemin du fichier. Par défaut, `prices.db` dans le dossier des bases de
  /// l'application ; les tests passent `inMemoryDatabasePath`.
  final String? _path;

  late final Future<Database> _database = _open();

  static const int _version = 1;

  Future<Database> _open() async {
    final path = _path ?? p.join(await getDatabasesPath(), 'prices.db');
    return openDatabase(
      path,
      version: _version,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE price_series (
            symbol TEXT PRIMARY KEY,
            currency TEXT NOT NULL,
            exchange TEXT NOT NULL,
            fetched_at TEXT NOT NULL
          )
        ''');
        // Les dates sont au format AAAA-MM-JJ : l'ordre alphabétique est
        // aussi l'ordre chronologique.
        await db.execute('''
          CREATE TABLE price_points (
            symbol TEXT NOT NULL
              REFERENCES price_series (symbol) ON DELETE CASCADE,
            date TEXT NOT NULL,
            open REAL NOT NULL,
            high REAL NOT NULL,
            low REAL NOT NULL,
            close REAL NOT NULL,
            volume REAL,
            PRIMARY KEY (symbol, date)
          ) WITHOUT ROWID
        ''');
      },
    );
  }

  /// Historique enregistré de [symbol], ou `null` s'il n'a jamais été
  /// téléchargé.
  Future<PriceHistory?> load(String symbol) async {
    final db = await _database;

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
    final db = await _database;

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
