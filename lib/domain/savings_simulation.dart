import 'dart:math' as math;

import 'price_history.dart';

/// Rythme des versements.
enum ContributionFrequency {
  monthly('1 fois par mois', 12),
  twiceMonthly('2 fois par mois', 24);

  const ContributionFrequency(this.label, this.perYear);

  /// Nom affiché à l'utilisateur.
  final String label;

  /// Nombre de versements par an.
  final int perYear;
}

/// Paramètres d'un placement régulier, saisis par l'utilisateur.
class SavingsPlan {
  const SavingsPlan({
    this.initialAmount = 1000,
    this.contribution = 100,
    this.frequency = ContributionFrequency.monthly,
    this.years = 10,
    this.annualRate = 0.05,
  });

  /// Somme placée au départ.
  final double initialAmount;

  /// Somme ajoutée à chaque versement.
  final double contribution;

  final ContributionFrequency frequency;

  /// Durée du placement, en années.
  final int years;

  /// Rendement annuel espéré (0,05 pour 5 %). Ignoré par la simulation sur
  /// un historique réel, qui utilise les cours de l'actif.
  final double annualRate;

  SavingsPlan copyWith({
    double? initialAmount,
    double? contribution,
    ContributionFrequency? frequency,
    int? years,
    double? annualRate,
  }) {
    return SavingsPlan(
      initialAmount: initialAmount ?? this.initialAmount,
      contribution: contribution ?? this.contribution,
      frequency: frequency ?? this.frequency,
      years: years ?? this.years,
      annualRate: annualRate ?? this.annualRate,
    );
  }
}

/// État du placement à une date : somme versée et valeur atteinte.
class SavingsPoint {
  const SavingsPoint({
    required this.date,
    required this.invested,
    required this.value,
  });

  final DateTime date;

  /// Total des sommes versées jusqu'à cette date.
  final double invested;

  /// Valeur du placement à cette date.
  final double value;

  /// Gains (ou pertes, si négatif) : valeur moins sommes versées.
  double get gains => value - invested;
}

/// Projection d'un placement à rendement annuel constant, à partir de
/// [start] (aujourd'hui par défaut).
List<SavingsPoint> simulateCompoundInterest(
  SavingsPlan plan, {
  DateTime? start,
}) {
  // Une part vaut 1 au départ et grandit au taux annuel : sa valeur après
  // `i` versements est (1 + taux) ^ (i / versements par an).
  return _simulate(
    plan,
    dates: _contributionDates(start ?? DateTime.now(), plan),
    priceAt: (i) =>
        math.pow(1 + plan.annualRate, i / plan.frequency.perYear).toDouble(),
  );
}

/// Ce qu'aurait donné le placement sur les [SavingsPlan.years] dernières
/// années de [history], en achetant l'actif au cours de clôture de chaque
/// date de versement.
List<SavingsPoint> simulateHistoricalInvestment(
  SavingsPlan plan,
  PriceHistory history,
) {
  final last = history.points.last.date;
  final dates = _contributionDates(
    DateTime(last.year - plan.years, last.month, last.day),
    plan,
  );

  return _simulate(
    plan,
    dates: dates,
    priceAt: (i) => _closeOn(history, dates[i]),
  );
}

/// Rendement annuel moyen de l'actif sur les [years] dernières années de
/// [history] (0,08 pour 8 % par an).
double annualizedReturn(PriceHistory history, int years) {
  final last = history.points.last;
  final start =
      DateTime(last.date.year - years, last.date.month, last.date.day);
  final growth = last.close / _closeOn(history, start);
  return math.pow(growth, 1 / years).toDouble() - 1;
}

/// Nombre d'années complètes couvertes par [history], pour borner la durée de
/// la simulation sur historique réel.
int availableYears(PriceHistory history) {
  if (history.points.isEmpty) {
    return 0;
  }
  final first = history.points.first.date;
  final last = history.points.last.date;
  return last.difference(first).inDays ~/ 365.25;
}

/// Cours de clôture de la première séance à [date] ou après (les marchés sont
/// fermés le week-end et les jours fériés).
double _closeOn(PriceHistory history, DateTime date) {
  return history.points
      .firstWhere(
        (point) => !point.date.isBefore(date),
        orElse: () => history.points.last,
      )
      .close;
}

/// Cœur commun aux deux simulations : au départ, le montant initial achète
/// des parts ; à chaque versement suivant, la somme versée en achète d'autres
/// au prix du moment. La valeur du placement est le nombre de parts multiplié
/// par leur prix.
List<SavingsPoint> _simulate(
  SavingsPlan plan, {
  required List<DateTime> dates,
  required double Function(int index) priceAt,
}) {
  final result = <SavingsPoint>[];
  var shares = 0.0;
  var invested = 0.0;

  for (var i = 0; i < dates.length; i++) {
    final amount = i == 0 ? plan.initialAmount : plan.contribution;
    final price = priceAt(i);
    shares += amount / price;
    invested += amount;
    result.add(
      SavingsPoint(date: dates[i], invested: invested, value: shares * price),
    );
  }
  return result;
}

/// Dates des versements à partir de [start], pendant [SavingsPlan.years]
/// ans : chaque mois, ou chaque mois et 15 jours plus tard pour deux
/// versements par mois. La première date est celle du montant initial.
List<DateTime> _contributionDates(DateTime start, SavingsPlan plan) {
  final count = plan.years * plan.frequency.perYear;
  return [
    for (var i = 0; i <= count; i++)
      switch (plan.frequency) {
        ContributionFrequency.monthly =>
          DateTime(start.year, start.month + i, start.day),
        ContributionFrequency.twiceMonthly => DateTime(
            start.year,
            start.month + i ~/ 2,
            start.day + (i.isOdd ? 15 : 0),
          ),
      },
  ];
}
