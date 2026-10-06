import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/price_history.dart';

/// Erreur renvoyée par l'API de cours, avec un message affichable tel quel.
class MarketDataException implements Exception {
  const MarketDataException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Télécharge les historiques de cours depuis l'API Twelve Data.
///
/// L'offre gratuite autorise 8 appels par minute et 800 par jour : chaque
/// téléchargement compte pour un appel, d'où l'enregistrement en base (voir
/// `PriceRepository`).
class TwelveDataClient {
  TwelveDataClient({required this.apiKey, http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  /// Clé fournie au lancement : `--dart-define-from-file=env.json`.
  static const String apiKeyFromEnvironment =
      String.fromEnvironment('TWELVE_DATA_API_KEY');

  final String apiKey;
  final http.Client _http;

  /// Cours quotidiens de [symbol] depuis [from] jusqu'à aujourd'hui.
  Future<PriceHistory> fetchDailyHistory(
    String symbol, {
    required DateTime from,
  }) async {
    if (apiKey.isEmpty) {
      throw const MarketDataException(
        'Clé de l’API de cours absente : lancez l’application avec '
        '--dart-define-from-file=env.json.',
      );
    }

    final uri = Uri.https('api.twelvedata.com', '/time_series', {
      'symbol': symbol,
      'interval': '1day',
      'start_date': _formatDate(from),
      // 5000 est le maximum ; 10 ans de séances en font environ 2 500.
      'outputsize': '5000',
      'order': 'asc',
    });

    final http.Response response;
    try {
      response = await _http.get(
        uri,
        headers: {'Authorization': 'apikey $apiKey'},
      );
    } on http.ClientException {
      throw const MarketDataException(
        'Impossible de joindre le serveur des cours. Vérifiez la connexion.',
      );
    }

    final Map<String, dynamic> json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException {
      throw MarketDataException(_errorMessage(response.statusCode));
    }

    // L'API répond souvent 200 même en cas d'erreur : c'est le champ
    // `status` du JSON qui fait foi.
    if (json['status'] != 'ok') {
      throw MarketDataException(_errorMessage(json['code']));
    }

    final meta = json['meta'] as Map<String, dynamic>;
    final values = json['values'] as List<dynamic>;

    return PriceHistory(
      symbol: symbol,
      // Les cryptomonnaies n'ont pas de `currency` mais une devise de
      // cotation (`currency_quote`), par exemple « US Dollar ».
      currency: (meta['currency'] ?? meta['currency_quote']) as String? ?? '',
      exchange: meta['exchange'] as String? ?? '',
      fetchedAt: DateTime.now(),
      points: [
        for (final value in values.cast<Map<String, dynamic>>())
          PricePoint(
            date: DateTime.parse(value['datetime'] as String),
            open: double.parse(value['open'] as String),
            high: double.parse(value['high'] as String),
            low: double.parse(value['low'] as String),
            close: double.parse(value['close'] as String),
            volume: double.tryParse(value['volume'] as String? ?? ''),
          ),
      ],
    );
  }

  static String _errorMessage(Object? code) {
    return switch (code) {
      429 => 'Limite de 8 téléchargements par minute atteinte. '
          'Réessayez dans une minute.',
      401 || 403 => 'L’API de cours a refusé la clé ou ce symbole.',
      404 || 400 => 'Cet actif est introuvable sur l’API de cours.',
      _ => 'L’API de cours a renvoyé une erreur. Réessayez plus tard.',
    };
  }

  /// Date au format attendu par l'API, par exemple « 2016-10-06 ».
  static String _formatDate(DateTime date) {
    return date.toIso8601String().substring(0, 10);
  }
}
