import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/app_preferences.dart';
import 'data/connectivity_service.dart';

/// Point d'entrée de l'application.
///
/// On ouvre le stockage local avant d'afficher quoi que ce soit : dès la
/// première image, l'application sait s'il faut montrer l'écran de bienvenue.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = await SharedPreferences.getInstance();

  runApp(
    InvestmentCompanionApp(
      preferences: AppPreferences(store),
      connectivityService: const SocketConnectivityService(),
    ),
  );
}
