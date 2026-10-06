import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_text_styles.dart';
import '../../domain/currency.dart';
import '../../domain/saved_simulation.dart';
import '../../domain/savings_simulation.dart';
import '../../state/settings_controller.dart';
import 'widgets/save_simulation_button.dart';
import 'widgets/savings_plan_form.dart';
import 'widgets/savings_result.dart';

/// Calculateur d'intérêts composés : projection d'un placement régulier à
/// rendement annuel constant. Fonctionne hors connexion.
///
/// Avec [savedSimulation] (simulation enregistrée rouverte), le formulaire
/// est prérempli et le bouton met à jour la simulation au lieu d'en
/// enregistrer une nouvelle.
class CompoundInterestScreen extends StatefulWidget {
  const CompoundInterestScreen({super.key, this.savedSimulation});

  final SavedSimulation? savedSimulation;

  @override
  State<CompoundInterestScreen> createState() => _CompoundInterestScreenState();
}

class _CompoundInterestScreenState extends State<CompoundInterestScreen> {
  late SavingsPlan _plan = widget.savedSimulation?.plan ?? const SavingsPlan();

  @override
  Widget build(BuildContext context) {
    final currency = context.select<SettingsController, Currency>(
      (settings) => settings.currency.display,
    );
    final points = simulateCompoundInterest(_plan);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          const Text('Intérêts composés', style: AppTextStyles.title),
          const SizedBox(height: 4),
          const Text(
            'Les gains de chaque année produisent à leur tour des gains.',
            style: AppTextStyles.bodyMuted,
          ),
          const SizedBox(height: 20),
          SavingsPlanForm(
            plan: _plan,
            onChanged: (plan) => setState(() => _plan = plan),
            currency: currency.symbol,
            maxYears: 40,
          ),
          const SizedBox(height: 24),
          SavingsResult(points: points, currency: currency.symbol),
          const SizedBox(height: 16),
          SaveSimulationButton(
            simulation: SavedSimulation(
              id: widget.savedSimulation?.id,
              createdAt: DateTime.now(),
              currency: currency.symbol,
              plan: _plan,
              invested: points.last.invested,
              finalValue: points.last.value,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Projection à rendement constant, avant frais et impôts : '
            'un placement réel varie d’une année sur l’autre.',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
