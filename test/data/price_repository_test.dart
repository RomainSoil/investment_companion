import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:investment_companion/data/price_database.dart';
import 'package:investment_companion/data/price_repository.dart';
import 'package:investment_companion/data/twelve_data_client.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Réponse de l'API pour AAPL, réduite à deux séances.
const _aaplResponse = {
  'meta': {'symbol': 'AAPL', 'currency': 'USD', 'exchange': 'NASDAQ'},
  'values': [
    {
      'datetime': '2016-10-06',
      'open': '28.42500',
      'high': '28.58500',
      'low': '28.28250',
      'close': '28.47250',
      'volume': '115117200',
    },
    {
      'datetime': '2016-10-07',
      'open': '28.57750',
      'high': '28.64000',
      'low': '28.37750',
      'close': '28.51500',
      'volume': '97433600',
    },
  ],
  'status': 'ok',
};

/// Réponse de l'API pour le bitcoin : ni `currency`, ni volume.
const _bitcoinResponse = {
  'meta': {
    'symbol': 'BTC/USD',
    'currency_base': 'Bitcoin',
    'currency_quote': 'US Dollar',
    'exchange': 'Binance',
  },
  'values': [
    {
      'datetime': '2026-10-06',
      'open': '62000.5',
      'high': '63000',
      'low': '61000',
      'close': '62500.25',
    },
  ],
  'status': 'ok',
};

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late PriceDatabase database;
  late List<http.Request> requests;

  /// Dépôt dont l'API répond [body] à chaque appel.
  PriceRepository repositoryAnswering(Map<String, Object?> body) {
    final client = MockClient((request) async {
      requests.add(request);
      return http.Response(jsonEncode(body), 200);
    });
    return PriceRepository(
      database: database,
      client: TwelveDataClient(apiKey: 'test', httpClient: client),
    );
  }

  setUp(() async {
    // Une base neuve par test.
    await databaseFactory.deleteDatabase(inMemoryDatabasePath);
    database = PriceDatabase(path: inMemoryDatabasePath);
    requests = [];
  });

  test('télécharge un actif absent de la base, puis le relit sans appel',
      () async {
    final repository = repositoryAnswering(_aaplResponse);

    final downloaded = await repository.dailyHistory('AAPL');
    final reloaded = await repository.dailyHistory('AAPL');

    expect(requests, hasLength(1));
    expect(requests.single.url.queryParameters['symbol'], 'AAPL');
    expect(requests.single.headers['Authorization'], 'apikey test');

    for (final history in [downloaded, reloaded]) {
      expect(history.currency, 'USD');
      expect(history.exchange, 'NASDAQ');
      expect(history.points, hasLength(2));
      expect(history.points.first.date, DateTime(2016, 10, 6));
      expect(history.points.last.close, 28.515);
      expect(history.points.last.volume, 97433600);
    }
  });

  test('deux demandes simultanées ne font qu’un appel', () async {
    final repository = repositoryAnswering(_aaplResponse);

    await Future.wait([
      repository.dailyHistory('AAPL'),
      repository.dailyHistory('AAPL'),
    ]);

    expect(requests, hasLength(1));
  });

  test('enregistre une cryptomonnaie sans volume', () async {
    final repository = repositoryAnswering(_bitcoinResponse);

    await repository.dailyHistory('BTC/USD');
    final history = await database.load('BTC/USD');

    expect(history, isNotNull);
    expect(history!.currency, 'US Dollar');
    expect(history.points.single.close, 62500.25);
    expect(history.points.single.volume, isNull);
  });

  test('une limite atteinte donne un message clair et rien n’est enregistré',
      () async {
    final repository = repositoryAnswering({
      'code': 429,
      'message': 'You have run out of API credits for the current minute.',
      'status': 'error',
    });

    await expectLater(
      repository.dailyHistory('AAPL'),
      throwsA(
        isA<MarketDataException>().having(
          (error) => error.message,
          'message',
          contains('Réessayez dans une minute'),
        ),
      ),
    );
    expect(await database.load('AAPL'), isNull);

    // « Réessayer » relance un appel, un seul.
    await expectLater(
      repository.dailyHistory('AAPL'),
      throwsA(isA<MarketDataException>()),
    );
    expect(requests, hasLength(2));
  });
}
