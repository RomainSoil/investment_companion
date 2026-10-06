import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../domain/currency.dart';
import '../../domain/price_history.dart';
import '../../domain/saved_simulation.dart';
import '../../domain/savings_simulation.dart';
import '../../state/settings_controller.dart';
import '../calculator/widgets/save_simulation_button.dart';
import '../calculator/widgets/savings_plan_form.dart';
import '../calculator/widgets/savings_result.dart';

/// « Et si j'avais investi ? » : le placement régulier de [plan], rejoué sur
/// les vrais cours de l'actif. Aucun appel à l'API : l'historique est déjà
/// chargé.
///
/// Les montants sont saisis et affichés dans la devise choisie dans les
/// paramètres. Le taux de change étant fixe, il ne change pas le résultat :
/// chaque versement achète la même fraction de part dans les deux devises.
class WhatIfSection extends StatelessWidget {
  const WhatIfSection({
    super.key,
    required this.assetName,
    required this.history,
    required this.plan,
    required this.onPlanChanged,
    this.savedSimulationId,
  });

  final String assetName;
  final PriceHistory history;
  final SavingsPlan plan;
  final ValueChanged<SavingsPlan> onPlanChanged;

  /// Identifiant de la simulation enregistrée rouverte, que le bouton met à
  /// jour ; `null` pour une nouvelle simulation.
  final int? savedSimulationId;

  @override
  Widget build(BuildContext context) {
    final currency = context.select<SettingsController, Currency>(
      (settings) => settings.currency.display,
    );
    final maxYears = availableYears(history);
    if (maxYears < 1) {
      return const Text(
        'Historique trop court pour simuler un placement.',
        style: AppTextStyles.bodyMuted,
      );
    }

    // La durée ne peut pas dépasser l'historique disponible.
    final shownPlan = plan.copyWith(years: math.min(plan.years, maxYears));
    final yearlyReturn = annualizedReturn(history, shownPlan.years);
    final points = simulateHistoricalInvestment(shownPlan, history);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Et si j’avais investi\u00A0?',
            style: AppTextStyles.heading),
        const SizedBox(height: 4),
        Text(
          'Rendement moyen de ${history.symbol} sur ${shownPlan.years} '
          'an${shownPlan.years > 1 ? 's' : ''} : '
          '${formatChange(yearlyReturn)} par an.',
          style: AppTextStyles.bodyMuted,
        ),
        const SizedBox(height: 16),
        SavingsPlanForm(
          plan: shownPlan,
          onChanged: onPlanChanged,
          currency: currency.symbol,
          maxYears: maxYears,
          showRate: false,
        ),
        const SizedBox(height: 24),
        SavingsResult(points: points, currency: currency.symbol),
        const SizedBox(height: 16),
        SaveSimulationButton(
          simulation: SavedSimulation(
            id: savedSimulationId,
            createdAt: DateTime.now(),
            assetSymbol: history.symbol,
            assetName: assetName,
            currency: currency.symbol,
            plan: shownPlan.copyWith(annualRate: yearlyReturn),
            invested: points.last.invested,
            finalValue: points.last.value,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Chaque versement achète l’actif au cours de clôture du jour, hors '
          'frais et hors dividendes. Les performances passées ne préjugent '
          'pas des performances futures.',
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}
