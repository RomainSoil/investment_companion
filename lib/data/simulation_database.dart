import '../domain/saved_simulation.dart';
import '../domain/savings_simulation.dart';
import 'app_database.dart';

/// Simulations enregistrées, dans la table `saved_simulations` (voir
/// [AppDatabase]).
class SimulationDatabase {
  SimulationDatabase(this._appDatabase);

  final AppDatabase _appDatabase;

  static const String _table = 'saved_simulations';

  /// Toutes les simulations, de la plus récente à la plus ancienne.
  Future<List<SavedSimulation>> loadAll() async {
    final db = await _appDatabase.database;
    final rows = await db.query(_table, orderBy: 'created_at DESC');

    return [
      for (final row in rows)
        SavedSimulation(
          id: row['id'] as int,
          createdAt: DateTime.parse(row['created_at'] as String),
          assetSymbol: row['asset_symbol'] as String?,
          assetName: row['asset_name'] as String?,
          currency: row['currency'] as String,
          plan: SavingsPlan(
            initialAmount: (row['initial_amount'] as num).toDouble(),
            contribution: (row['contribution'] as num).toDouble(),
            frequency:
                ContributionFrequency.values.byName(row['frequency'] as String),
            years: row['years'] as int,
            annualRate: (row['annual_rate'] as num).toDouble(),
          ),
          invested: (row['invested'] as num).toDouble(),
          finalValue: (row['final_value'] as num).toDouble(),
        ),
    ];
  }

  Future<void> insert(SavedSimulation simulation) async {
    final db = await _appDatabase.database;
    await db.insert(_table, {
      'created_at': simulation.createdAt.toIso8601String(),
      'asset_symbol': simulation.assetSymbol,
      'asset_name': simulation.assetName,
      'currency': simulation.currency,
      'initial_amount': simulation.plan.initialAmount,
      'contribution': simulation.plan.contribution,
      'frequency': simulation.plan.frequency.name,
      'years': simulation.plan.years,
      'annual_rate': simulation.plan.annualRate,
      'invested': simulation.invested,
      'final_value': simulation.finalValue,
    });
  }

  Future<void> delete(int id) async {
    final db = await _appDatabase.database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
