import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../domain/asset.dart';
import '../../domain/saved_simulation.dart';
import '../../state/simulations_controller.dart';
import '../assets/asset_detail_screen.dart';
import '../calculator/compound_interest_screen.dart';

/// Onglet « Mes simulations » : les simulations enregistrées sur le
/// téléphone, consultables hors connexion.
class SavedSimulationsScreen extends StatelessWidget {
  const SavedSimulationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final simulations = context.watch<SimulationsController>().simulations;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          const Text('Mes simulations', style: AppTextStyles.title),
          const SizedBox(height: 16),
          if (simulations.isEmpty)
            const Text(
              'Aucune simulation enregistrée. Utilisez « Enregistrer la '
              'simulation » dans le calculateur ou sur la fiche d’un actif.',
              style: AppTextStyles.bodyMuted,
            ),
          for (final simulation in simulations) ...[
            _SimulationCard(simulation: simulation),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _SimulationCard extends StatelessWidget {
  const _SimulationCard({required this.simulation});

  final SavedSimulation simulation;

  /// Écran d'origine de la simulation, prérempli avec ses paramètres, ou
  /// `null` si son actif ne figure plus au catalogue.
  Widget? _originScreen() {
    final symbol = simulation.assetSymbol;
    if (symbol == null) {
      return Scaffold(
        appBar: AppBar(),
        body: CompoundInterestScreen(initialPlan: simulation.plan),
      );
    }
    final asset = assetBySymbol(symbol);
    return asset == null
        ? null
        : AssetDetailScreen(asset: asset, initialPlan: simulation.plan);
  }

  @override
  Widget build(BuildContext context) {
    final plan = simulation.plan;
    final currency = simulation.currency;
    final title = simulation.isHistorical
        ? 'Et si j’avais investi · ${simulation.assetName}'
        : 'Intérêts composés';
    final rateLabel =
        simulation.isHistorical ? 'rendement réel' : 'rendement espéré';

    final origin = _originScreen();

    // Même présentation que les tuiles de l'accueil : carte cliquable avec
    // effet d'appui.
    return Material(
      color: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        side: BorderSide(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: origin == null
            ? null
            : () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => origin),
                ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 4, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(title, style: AppTextStyles.label)),
                  IconButton(
                    tooltip: 'Supprimer',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => context
                        .read<SimulationsController>()
                        .delete(simulation),
                  ),
                ],
              ),
              Text(
                '${formatPrice(plan.initialAmount, currency)} puis '
                '${formatPrice(plan.contribution, currency)} '
                '${plan.frequency.label}, pendant ${plan.years} an'
                '${plan.years > 1 ? 's' : ''} · $rateLabel '
                '${formatChange(plan.annualRate)} par an',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 12),
              Text(
                formatPrice(simulation.finalValue, currency),
                style: AppTextStyles.heading,
              ),
              Text(
                'Versé ${formatPrice(simulation.invested, currency)} · '
                '${simulation.gains < 0 ? 'Pertes' : 'Gains'} '
                '${formatPrice(simulation.gains, currency)}',
                style: AppTextStyles.bodyMuted,
              ),
              const SizedBox(height: 4),
              Text(
                'Enregistrée le ${formatDate(simulation.createdAt)}',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
