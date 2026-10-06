import 'package:flutter/foundation.dart';

import '../domain/price_history.dart';
import 'price_database.dart';
import 'twelve_data_client.dart';

/// Donne l'historique des cours d'un actif en appelant l'API le moins
/// possible (8 appels par minute sur l'offre gratuite) :
/// - un actif n'est demandé qu'à l'ouverture de sa fiche ;
/// - un actif déjà en base est relu depuis la base, sans appel ;
/// - sinon, un seul appel, dont le résultat est enregistré en base.
class PriceRepository {
  PriceRepository({
    required PriceDatabase database,
    required TwelveDataClient client,
  })  : _database = database,
        _client = client;

  final PriceDatabase _database;
  final TwelveDataClient _client;

  /// Historiques demandés depuis le lancement, par symbole. Rouvrir un actif,
  /// même pendant son téléchargement, réutilise la même demande : jamais deux
  /// appels pour un même actif.
  final Map<String, Future<PriceHistory>> _histories = {};

  /// Historique de [symbol] sur les 10 dernières années.
  Future<PriceHistory> dailyHistory(String symbol) {
    return _histories.putIfAbsent(symbol, () {
      final history = _load(symbol);
      // En cas d'échec (réseau, limite atteinte), on oublie la demande pour
      // que « Réessayer » puisse en relancer une. Accolades et non `=>` :
      // `remove` renvoie le Future retiré, qui serait sinon attendu ici.
      history.then<void>(
        (_) {},
        onError: (Object _) {
          _histories.remove(symbol);
        },
      );
      return history;
    });
  }

  Future<PriceHistory> _load(String symbol) async {
    final saved = await _database.load(symbol);
    if (saved != null) {
      return saved;
    }

    final now = DateTime.now();
    final history = await _client.fetchDailyHistory(
      symbol,
      from: DateTime(now.year - 10, now.month, now.day),
    );

    // Si l'enregistrement échoue, on affiche quand même l'historique : il
    // reste en mémoire jusqu'à la fermeture, sans nouvel appel.
    try {
      await _database.save(history);
    } catch (error) {
      debugPrint('Historique $symbol non enregistré en base : $error');
    }
    return history;
  }
}
