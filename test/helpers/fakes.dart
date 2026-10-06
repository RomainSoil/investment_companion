import 'dart:async';

import 'package:investment_companion/data/connectivity_service.dart';
import 'package:investment_companion/data/price_repository.dart';
import 'package:investment_companion/data/simulation_database.dart';
import 'package:investment_companion/domain/price_history.dart';
import 'package:investment_companion/domain/saved_simulation.dart';

/// Service de connexion factice : répond tout de suite, en ligne ou non.
class FakeConnectivityService implements ConnectivityService {
  FakeConnectivityService({this.online = true});

  /// Réponse donnée aux prochaines vérifications.
  bool online;

  /// Nombre de vérifications demandées.
  int calls = 0;

  @override
  Future<bool> hasInternet() async {
    calls++;
    return online;
  }
}

/// Service dont le test décide lui-même quand il répond, pour observer ce qui
/// se passe pendant une vérification.
class PendingConnectivityService implements ConnectivityService {
  final List<Completer<bool>> requests = [];

  @override
  Future<bool> hasInternet() {
    final completer = Completer<bool>();
    requests.add(completer);
    return completer.future;
  }
}

/// Service qui échoue toujours.
class FailingConnectivityService implements ConnectivityService {
  @override
  Future<bool> hasInternet() async {
    throw StateError('panne simulée');
  }
}

/// Simulations gardées en mémoire, à la place de la base SQLite : dans un
/// test d'écran, le temps est simulé et les requêtes SQLite ne se
/// termineraient pas.
class FakeSimulationDatabase implements SimulationDatabase {
  FakeSimulationDatabase([List<SavedSimulation> simulations = const []]) {
    simulations.forEach(insert);
  }

  final List<SavedSimulation> _simulations = [];
  int _nextId = 1;

  @override
  Future<List<SavedSimulation>> loadAll() async {
    return _simulations.reversed.toList();
  }

  @override
  Future<void> insert(SavedSimulation simulation) async {
    _simulations.add(
      SavedSimulation(
        id: _nextId++,
        createdAt: simulation.createdAt,
        assetSymbol: simulation.assetSymbol,
        assetName: simulation.assetName,
        currency: simulation.currency,
        plan: simulation.plan,
        invested: simulation.invested,
        finalValue: simulation.finalValue,
      ),
    );
  }

  @override
  Future<void> delete(int id) async {
    _simulations.removeWhere((simulation) => simulation.id == id);
  }
}

/// Dépôt de cours sans base ni réseau : chaque actif a 3 ans de cours qui
/// montent de 1 par jour.
class FakePriceRepository implements PriceRepository {
  @override
  Future<PriceHistory> dailyHistory(String symbol) async {
    return PriceHistory(
      symbol: symbol,
      currency: 'USD',
      exchange: 'TEST',
      fetchedAt: DateTime(2026),
      points: [
        for (var i = 0; i <= 3 * 366; i++)
          PricePoint(
            date: DateTime(2023, 1, 1 + i),
            open: 100,
            high: 100,
            low: 100,
            close: 100.0 + i,
          ),
      ],
    );
  }
}
