import 'dart:io';

import 'package:flutter/foundation.dart';

/// Indique si Internet est joignable.
///
/// C'est une interface : l'application utilise [SocketConnectivityService],
/// les tests la remplacent par une version factice.
abstract class ConnectivityService {
  Future<bool> hasInternet();
}

/// Vérifie la connexion en ouvrant brièvement une connexion vers un serveur.
///
/// Par défaut, on vise le serveur de l'API de cours prévue dans la
/// proposition : s'il est joignable, les simulations pourront télécharger
/// leurs données.
class SocketConnectivityService implements ConnectivityService {
  const SocketConnectivityService({
    this.host = 'api.twelvedata.com',
    this.port = 443,
    this.timeout = const Duration(seconds: 4),
  });

  final String host;
  final int port;
  final Duration timeout;

  @override
  Future<bool> hasInternet() async {
    // `dart:io` n'existe pas dans un navigateur : si l'application tourne en
    // version web, on considère qu'elle est en ligne.
    if (kIsWeb) {
      return true;
    }

    try {
      final socket = await Socket.connect(host, port, timeout: timeout);
      socket.destroy();
      return true;
    } on SocketException {
      // Pas de réseau, serveur introuvable ou délai dépassé.
      return false;
    }
  }
}
