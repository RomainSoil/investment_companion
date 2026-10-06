import 'package:flutter/foundation.dart';

import '../data/simulation_database.dart';
import '../domain/saved_simulation.dart';

/// Simulations enregistrées, partagées entre les écrans qui en enregistrent
/// et l'onglet « Mes simulations » qui les affiche.
class SimulationsController extends ChangeNotifier {
  SimulationsController(this._database);

  final SimulationDatabase _database;

  List<SavedSimulation> _simulations = [];

  /// De la plus récente à la plus ancienne.
  List<SavedSimulation> get simulations => List.unmodifiable(_simulations);

  /// Lit les simulations enregistrées sur le téléphone.
  Future<void> load() async {
    _simulations = await _database.loadAll();
    notifyListeners();
  }

  /// Enregistre [simulation], puis relit la liste pour obtenir son
  /// identifiant en base.
  Future<void> save(SavedSimulation simulation) async {
    await _database.insert(simulation);
    await load();
  }

  Future<void> delete(SavedSimulation simulation) async {
    final id = simulation.id;
    if (id == null) {
      return;
    }
    _simulations = _simulations.where((other) => other.id != id).toList();
    notifyListeners();
    await _database.delete(id);
  }
}
