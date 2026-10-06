import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/saved_simulation.dart';
import '../../../state/navigation_controller.dart';
import '../../../state/simulations_controller.dart';

/// Enregistre [simulation] dans « Mes simulations » et le confirme.
///
/// Une simulation déjà enregistrée (avec un identifiant) est mise à jour au
/// lieu d'être enregistrée une seconde fois.
class SaveSimulationButton extends StatelessWidget {
  const SaveSimulationButton({super.key, required this.simulation});

  final SavedSimulation simulation;

  bool get _isUpdate => simulation.id != null;

  Future<void> _save(BuildContext context) async {
    // Récupérés avant l'attente : le contexte peut ne plus être valide après.
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final navigation = context.read<NavigationController>();

    await context.read<SimulationsController>().save(simulation);

    // Remplace un éventuel message précédent au lieu d'attendre sa fin.
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          _isUpdate ? 'Simulation mise à jour.' : 'Simulation enregistrée.',
        ),
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
      icon: Icon(_isUpdate ? Icons.save_outlined : Icons.bookmark_add_outlined),
      label: Text(
        _isUpdate ? 'Mettre à jour la simulation' : 'Enregistrer la simulation',
      ),
    );
  }
}
