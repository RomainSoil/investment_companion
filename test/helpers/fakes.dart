import 'dart:async';

import 'package:investment_companion/data/connectivity_service.dart';

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
