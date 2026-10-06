import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/number_field.dart';
import '../../../domain/savings_simulation.dart';

/// Saisie des paramètres d'un placement régulier.
///
/// Le formulaire ne garde aucun état : chaque modification est transmise à
/// [onChanged], et l'écran parent lui redonne le nouveau [plan].
class SavingsPlanForm extends StatelessWidget {
  const SavingsPlanForm({
    super.key,
    required this.plan,
    required this.onChanged,
    required this.currency,
    required this.maxYears,
    this.showRate = true,
  });

  final SavingsPlan plan;
  final ValueChanged<SavingsPlan> onChanged;

  /// Devise des montants, par exemple « € » ou « USD ».
  final String currency;

  /// Durée maximale proposée, en années.
  final int maxYears;

  /// Affiche le champ « rendement annuel espéré ». Masqué pour une simulation
  /// sur historique réel, où le rendement est celui de l'actif.
  final bool showRate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NumberField(
          label: 'Montant initial',
          suffix: currency,
          value: plan.initialAmount,
          onChanged: (value) => onChanged(plan.copyWith(initialAmount: value)),
        ),
        const SizedBox(height: 12),
        NumberField(
          label: 'Montant épargné à chaque versement',
          suffix: currency,
          value: plan.contribution,
          onChanged: (value) => onChanged(plan.copyWith(contribution: value)),
        ),
        const SizedBox(height: 12),
        SegmentedButton<ContributionFrequency>(
          segments: [
            for (final frequency in ContributionFrequency.values)
              ButtonSegment(value: frequency, label: Text(frequency.label)),
          ],
          selected: {plan.frequency},
          onSelectionChanged: (selection) =>
              onChanged(plan.copyWith(frequency: selection.single)),
        ),
        if (showRate) ...[
          const SizedBox(height: 12),
          NumberField(
            label: 'Rendement annuel espéré',
            suffix: '%',
            value: plan.annualRate * 100,
            onChanged: (value) =>
                onChanged(plan.copyWith(annualRate: value / 100)),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          'Durée : ${plan.years} an${plan.years > 1 ? 's' : ''}',
          style: AppTextStyles.label,
        ),
        if (maxYears > 1)
          Slider(
            value: plan.years.toDouble(),
            min: 1,
            max: maxYears.toDouble(),
            divisions: maxYears - 1,
            label: '${plan.years} ans',
            onChanged: (value) =>
                onChanged(plan.copyWith(years: value.round())),
          ),
      ],
    );
  }
}
