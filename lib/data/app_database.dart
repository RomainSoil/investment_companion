import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Base SQLite de l'application : ouverture, structure et mises à jour.
///
/// Les tables sont lues et écrites par [PriceDatabase] (cours) et
/// [SimulationDatabase] (simulations enregistrées). La base est ouverte au
/// premier accès.
///
/// Structure :
/// - `price_series` : une ligne par actif téléchargé (devise, place de
///   cotation, date du téléchargement) ;
/// - `price_points` : une ligne par actif et par jour de cotation ;
/// - `saved_simulations` : une ligne par simulation enregistrée.
class AppDatabase {
  AppDatabase({String? path}) : _path = path;

  /// Chemin du fichier. Par défaut, `prices.db` dans le dossier des bases de
  /// l'application ; les tests passent `inMemoryDatabasePath`.
  final String? _path;

  /// Version 1 : cours. Version 2 : ajout des simulations enregistrées.
  static const int _version = 2;

  late final Future<Database> database = _open();

  Future<Database> _open() async {
    final path = _path ?? p.join(await getDatabasesPath(), 'prices.db');
    return openDatabase(
      path,
      version: _version,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, version) async {
        await _createPriceTables(db);
        await _createSimulationTable(db);
      },
      // Une base créée par une version précédente de l'application garde ses
      // cours ; on ajoute seulement ce qui manque.
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createSimulationTable(db);
        }
      },
    );
  }

  static Future<void> _createPriceTables(Database db) async {
    await db.execute('''
      CREATE TABLE price_series (
        symbol TEXT PRIMARY KEY,
        currency TEXT NOT NULL,
        exchange TEXT NOT NULL,
        fetched_at TEXT NOT NULL
      )
    ''');
    // Les dates sont au format AAAA-MM-JJ : l'ordre alphabétique est aussi
    // l'ordre chronologique.
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
  }

  static Future<void> _createSimulationTable(Database db) async {
    // `asset_symbol` vide : simulation d'intérêts composés. Sinon, simulation
    // « Et si j'avais investi ? » sur cet actif, et `annual_rate` est son
    // rendement annuel moyen réel.
    await db.execute('''
      CREATE TABLE saved_simulations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        created_at TEXT NOT NULL,
        asset_symbol TEXT,
        asset_name TEXT,
        currency TEXT NOT NULL,
        initial_amount REAL NOT NULL,
        contribution REAL NOT NULL,
        frequency TEXT NOT NULL,
        years INTEGER NOT NULL,
        annual_rate REAL NOT NULL,
        invested REAL NOT NULL,
        final_value REAL NOT NULL
      )
    ''');
  }
}
