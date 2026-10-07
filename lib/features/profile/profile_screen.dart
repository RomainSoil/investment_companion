import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_text_styles.dart';
import '../../core/utils/navigation.dart';
import '../../domain/investor_profile.dart';
import '../../state/app_controller.dart';
import '../assets/asset_tile.dart';
import '../settings/settings_screen.dart';
import 'questionnaire_screen.dart';

/// Onglet « Profil » : profil investisseur et actifs conseillés, ou invitation
/// à répondre au questionnaire. Donne aussi accès aux paramètres.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.select<AppController, InvestorProfileType?>(
      (app) => app.profile,
    );

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Text(
            profile == null ? 'Votre profil' : 'Profil ${profile.label}',
            style: AppTextStyles.title,
          ),
          const SizedBox(height: 8),
          Text(
            profile?.description ??
                'Répondez à 5 questions pour connaître votre profil '
                    'd’investisseur et les actifs qui vous correspondent.',
            style: AppTextStyles.bodyMuted,
          ),
          const SizedBox(height: 16),
          if (profile == null)
            FilledButton(
              onPressed: () => openScreen(context, const QuestionnaireScreen()),
              child: const Text('Commencer le questionnaire'),
            )
          else ...[
            Text(
              'ACTIFS CONSEILLÉS · RISQUE '
              '${profile.advisedRisk.label.toUpperCase()}',
              style: AppTextStyles.overline,
            ),
            for (final asset in profile.advisedAssets) AssetTile(asset: asset),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => openScreen(context, const QuestionnaireScreen()),
              child: const Text('Refaire le questionnaire'),
            ),
          ],
          const Divider(height: 40),
          TextButton.icon(
            onPressed: () => openScreen(context, const SettingsScreen()),
            icon: const Icon(Icons.settings_outlined),
            label: const Text('Paramètres'),
          ),
          TextButton(
            onPressed: () => context.read<AppController>().showWelcomeAgain(),
            child: const Text('Revoir l’écran de bienvenue'),
          ),
        ],
      ),
    );
  }
}
