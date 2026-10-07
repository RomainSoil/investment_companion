import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:investment_companion/data/app_database.dart';
import 'package:investment_companion/data/simulation_database.dart';
import 'package:investment_companion/domain/saved_simulation.dart';
import 'package:investment_companion/domain/savings_simulation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  setUp(() => databaseFactory.deleteDatabase(inMemoryDatabasePath));

  test('enregistre, relit et supprime une simulation', () async {
    final database = SimulationDatabase(
      AppDatabase(path: inMemoryDatabasePath),
    );

    await database.save(
      SavedSimulation(
        createdAt: DateTime(2026, 10, 6),
        assetSymbol: 'SPY',
        assetName: 'SPDR S&P 500',
        currency: '€',
        plan: const SavingsPlan(
          frequency: ContributionFrequency.twiceMonthly,
          annualRate: 0.12,
        ),
        invested: 25000,
        finalValue: 41000,
      ),
    );

    final saved = (await database.loadAll()).single;
    expect(saved.id, isNotNull);
    expect(saved.isHistorical, isTrue);
    expect(saved.assetName, 'SPDR S&P 500');
    expect(saved.plan.frequency, ContributionFrequency.twiceMonthly);
    expect(saved.plan.annualRate, 0.12);
    expect(saved.gains, 16000);

    await database.delete(saved.id!);
    expect(await database.loadAll(), isEmpty);
  });

  test('ajoute la table des simulations à une base de la version 1', () async {
    // Base créée par la version précédente : cours seulement.
    final path = '${Directory.systemTemp.path}/ic_migration_test.db';
    await databaseFactory.deleteDatabase(path);
    final oldDatabase = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, _) => db.execute(
          'CREATE TABLE price_series (symbol TEXT PRIMARY KEY, '
          'currency TEXT NOT NULL, exchange TEXT NOT NULL, '
          'fetched_at TEXT NOT NULL)',
        ),
      ),
    );
    await oldDatabase.insert('price_series', {
      'symbol': 'SPY',
      'currency': 'USD',
      'exchange': 'NYSE',
      'fetched_at': '2026-10-06',
    });
    await oldDatabase.close();

    final appDatabase = AppDatabase(path: path);
    expect(await SimulationDatabase(appDatabase).loadAll(), isEmpty);

    // Les cours déjà téléchargés sont conservés.
    final db = await appDatabase.database;
    expect(await db.query('price_series'), hasLength(1));
    await db.close();
  });
}
