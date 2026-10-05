import 'package:flutter/foundation.dart';

import '../data/connectivity_service.dart';

/// États possibles de la connexion à Internet.
enum ConnectionStatus {
  /// État initial : la première vérification n'est pas terminée.
  checking,

  /// La dernière vérification a réussi.
  online,

  /// La dernière vérification a échoué.
  offline,
}

/// Suit l'état de la connexion et prévient l'interface quand il change.
class ConnectivityController extends ChangeNotifier {
  ConnectivityController(this._service, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final ConnectivityService _service;

  /// Donne l'heure courante. Les tests fournissent une heure fixe.
  final DateTime Function() _clock;

  ConnectionStatus _status = ConnectionStatus.checking;
  DateTime? _lastCheckedAt;
  bool _checkInProgress = false;
  bool _disposed = false;

  ConnectionStatus get status => _status;

  /// Heure de la dernière vérification terminée.
  DateTime? get lastCheckedAt => _lastCheckedAt;

  bool get isOnline => _status == ConnectionStatus.online;

  /// Vrai pendant une nouvelle vérification, alors qu'un résultat précédent
  /// est toujours affiché (état « actualisation »).
  bool get isRefreshing =>
      _checkInProgress && _status != ConnectionStatus.checking;

  /// Vérifie la connexion. Un appel pendant une vérification déjà en cours
  /// est ignoré.
  Future<void> check() async {
    if (_checkInProgress) {
      return;
    }
    _checkInProgress = true;
    if (_status != ConnectionStatus.checking) {
      // Un résultat est déjà affiché : on signale l'actualisation.
      _notify();
    }

    bool online;
    try {
      online = await _service.hasInternet();
    } catch (_) {
      // Quelle que soit l'erreur, on se considère hors connexion.
      online = false;
    }

    _status = online ? ConnectionStatus.online : ConnectionStatus.offline;
    _lastCheckedAt = _clock();
    _checkInProgress = false;
    _notify();
  }

  /// Une vérification peut se terminer après la destruction du contrôleur :
  /// dans ce cas, il ne faut plus prévenir personne.
  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
