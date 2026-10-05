import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/investor_profile.dart';
import '../../state/app_controller.dart';
import 'coming_soon_screen.dart';

/// Onglet « Profil », provisoire tant que le questionnaire n'est pas développé.
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.select<AppController, InvestorProfileType?>(
      (app) => app.profile,
    );

    return ComingSoonScreen(
      icon: Icons.track_changes,
      title: profile == null ? 'Votre profil' : 'Profil ${profile.label}',
      message:
          'Le questionnaire de profil investisseur arrive à la prochaine étape '
          'du développement.',
      action: TextButton(
        onPressed: () => context.read<AppController>().showWelcomeAgain(),
        child: const Text('Revoir l’écran de bienvenue'),
      ),
    );
  }
}
