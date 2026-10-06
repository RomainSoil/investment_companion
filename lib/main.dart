import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'app.dart';
import 'data/app_preferences.dart';
import 'data/connectivity_service.dart';
import 'data/price_database.dart';
import 'data/price_repository.dart';
import 'data/twelve_data_client.dart';

/// Point d'entrée de l'application.
///
/// On ouvre le stockage local avant d'afficher quoi que ce soit : dès la
/// première image, l'application sait s'il faut montrer l'écran de bienvenue.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = await SharedPreferences.getInstance();

  // sqflite gère Android, iOS et macOS. Ailleurs, il faut lui indiquer quelle
  // version de SQLite utiliser : WebAssembly dans le navigateur, bibliothèque
  // native sur Windows et Linux.
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(
    InvestmentCompanionApp(
      preferences: AppPreferences(store),
      connectivityService: const SocketConnectivityService(),
      priceRepository: PriceRepository(
        database: PriceDatabase(),
        client: TwelveDataClient(
          apiKey: TwelveDataClient.apiKeyFromEnvironment,
        ),
      ),
    ),
  );
}
