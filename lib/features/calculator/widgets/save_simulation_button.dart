import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/saved_simulation.dart';
import '../../../state/navigation_controller.dart';
import '../../../state/simulations_controller.dart';

/// Enregistre [simulation] dans « Mes simulations » et le confirme.
class SaveSimulationButton extends StatelessWidget {
  const SaveSimulationButton({super.key, required this.simulation});

  final SavedSimulation simulation;

  Future<void> _save(BuildContext context) async {
    // Récupérés avant l'attente : le contexte peut ne plus être valide après.
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final navigation = context.read<NavigationController>();

    await context.read<SimulationsController>().save(simulation);

    messenger.showSnackBar(
      SnackBar(
        content: const Text('Simulation enregistrée.'),
        action: SnackBarAction(
          label: 'Voir',
          // Revient à l'écran principal, puis ouvre l'onglet.
          onPressed: () {
            navigator.popUntil((route) => route.isFirst);
            navigation.goTo(AppTab.simulations);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _save(context),
      icon: const Icon(Icons.bookmark_add_outlined),
      label: const Text('Enregistrer la simulation'),
    );
  }
}
