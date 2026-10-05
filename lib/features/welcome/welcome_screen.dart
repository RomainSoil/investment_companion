import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../state/app_controller.dart';
import '../../state/navigation_controller.dart';
import 'growth_chart.dart';

/// Écran du premier lancement : il présente l'application, sans compte ni
/// connexion, puis laisse entrer avec ou sans profil investisseur.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  /// Entre dans l'application sur l'onglet [tab] et retient que l'écran de
  /// bienvenue a été vu.
  void _enter(BuildContext context, AppTab tab) {
    context.read<NavigationController>().goTo(tab);
    context.read<AppController>().completeWelcome();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // La présentation défile si l'écran est petit ; les boutons
              // restent toujours visibles en bas.
              const Expanded(
                child: SingleChildScrollView(child: _WelcomeIntro()),
              ),
              const SizedBox(height: 12),
              const _PedagogicalNotice(),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => _enter(context, AppTab.profile),
                child: const Text('Définir mon profil'),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => _enter(context, AppTab.home),
                child: const Text('Explorer sans profil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeIntro extends StatelessWidget {
  const _WelcomeIntro();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.eco_outlined,
                size: 22,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Investment Companion',
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: double.infinity,
            height: 210,
            color: AppColors.primarySoft,
            padding: const EdgeInsets.fromLTRB(18, 26, 18, 18),
            child: const GrowthChart(),
          ),
        ),
        const SizedBox(height: 24),
        const Text('Investir, pas à pas.', style: AppTextStyles.display),
        const SizedBox(height: 12),
        const Text(
          'Découvrez votre profil d’investisseur, simulez sans risque avec de '
          'vraies données et apprenez les bases à votre rythme.',
          style: AppTextStyles.bodyMuted,
        ),
        const SizedBox(height: 18),
        const _FeatureLine(
          icon: Icons.track_changes,
          text: 'Un profil selon votre risque et vos objectifs',
        ),
        const _FeatureLine(
          icon: Icons.calculate_outlined,
          text: 'Calculateurs et simulations sur ETF et actions',
        ),
        const _FeatureLine(
          icon: Icons.menu_book_outlined,
          text: 'Des leçons courtes, disponibles hors connexion',
        ),
      ],
    );
  }
}

class _FeatureLine extends StatelessWidget {
  const _FeatureLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}

/// Rappel imposé par le sujet : l'application est uniquement pédagogique.
class _PedagogicalNotice extends StatelessWidget {
  const _PedagogicalNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Icon(Icons.shield_outlined, size: 18, color: AppColors.primary),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Application pédagogique\u00A0: aucune transaction réelle, aucune '
              'connexion à une banque ou à un courtier.',
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
