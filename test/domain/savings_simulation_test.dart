import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:investment_companion/domain/price_history.dart';
import 'package:investment_companion/domain/savings_simulation.dart';

/// Historique quotidien du 1er janvier 2020 au 1er janvier 2023 : le cours
/// vaut 100, puis 200 le dernier jour.
PriceHistory _history() {
  final start = DateTime(2020);
  final end = DateTime(2023);
  final days = end.difference(start).inDays;
  return PriceHistory(
    symbol: 'TEST',
    currency: 'USD',
    exchange: 'TEST',
    fetchedAt: end,
    points: [
      for (var i = 0; i <= days; i++)
        PricePoint(
          date: DateTime(2020, 1, 1 + i),
          open: 100,
          high: 100,
          low: 100,
          close: i == days ? 200 : 100,
        ),
    ],
  );
}

void main() {
  final start = DateTime(2026, 1, 1);

  group('simulateCompoundInterest', () {
    test('donne un point par versement, montant initial compris', () {
      const plan = SavingsPlan(
        initialAmount: 1000,
        contribution: 50,
        frequency: ContributionFrequency.twiceMonthly,
        years: 1,
      );

      final points = simulateCompoundInterest(plan, start: start);

      expect(points, hasLength(25));
      expect(points.first.date, start);
      expect(points.last.date, DateTime(2027, 1, 1));
      expect(points.last.invested, 1000 + 24 * 50);
    });

    test('sans rendement, la valeur reste égale à la somme versée', () {
      const plan = SavingsPlan(annualRate: 0);

      for (final point in simulateCompoundInterest(plan, start: start)) {
        expect(point.value, closeTo(point.invested, 1e-9));
        expect(point.gains, closeTo(0, 1e-9));
      }
    });

    test('applique le rendement annuel au montant initial', () {
      const plan = SavingsPlan(
        initialAmount: 1000,
        contribution: 0,
        years: 1,
        annualRate: 0.05,
      );

      final last = simulateCompoundInterest(plan, start: start).last;

      expect(last.value, closeTo(1050, 1e-9));
    });

    test('capitalise aussi les versements réguliers', () {
      // 1 000 € puis 100 € par mois pendant 10 ans à 5 % par an.
      const plan = SavingsPlan();

      final last = simulateCompoundInterest(plan, start: start).last;

      expect(last.invested, 13000);
      expect(last.value, closeTo(17065.21, 0.01));
    });
  });

  group('simulateHistoricalInvestment', () {
    test('achète au cours de chaque date de versement', () {
      const plan = SavingsPlan(
        initialAmount: 1000,
        contribution: 0,
        years: 1,
      );

      final points = simulateHistoricalInvestment(plan, _history());

      // 10 parts achetées à 100, qui valent 200 le dernier jour.
      expect(points.first.date, DateTime(2022));
      expect(points.last.value, closeTo(2000, 1e-9));
      expect(points.last.gains, closeTo(1000, 1e-9));
    });
  });

  test('annualizedReturn : un cours doublé en un an fait +100 % par an', () {
    expect(annualizedReturn(_history(), 1), closeTo(1, 1e-9));
  });

  test('availableYears compte les années complètes de l’historique', () {
    expect(availableYears(_history()), 3);
  });

  group('annualVolatility', () {
    test('est nulle pour un cours qui monte toujours au même rythme', () {
      final history = PriceHistory(
        symbol: 'TEST',
        currency: 'USD',
        exchange: 'TEST',
        fetchedAt: DateTime(2026),
        points: [
          for (var i = 0; i < 365; i++)
            PricePoint(
              date: DateTime(2025, 1, 1 + i),
              open: 1,
              high: 1,
              low: 1,
              close: 100 * math.pow(1.001, i).toDouble(),
            ),
        ],
      );

      expect(history.annualVolatility, closeTo(0, 1e-9));
    });

    test('augmente avec l’ampleur des variations', () {
      PriceHistory alternating(double amplitude) {
        return PriceHistory(
          symbol: 'TEST',
          currency: 'USD',
          exchange: 'TEST',
          fetchedAt: DateTime(2026),
          points: [
            for (var i = 0; i < 365; i++)
              PricePoint(
                date: DateTime(2025, 1, 1 + i),
                open: 1,
                high: 1,
                low: 1,
                close: i.isEven ? 100 : 100 * (1 + amplitude),
              ),
          ],
        );
      }

      expect(
        alternating(0.05).annualVolatility,
        greaterThan(alternating(0.01).annualVolatility),
      );
    });
  });
}
