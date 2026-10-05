import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/status_badge.dart';
import '../../domain/daily_tip.dart';
import '../../domain/investor_profile.dart';
import '../../state/app_controller.dart';
import '../../state/connectivity_controller.dart';
import '../../state/navigation_controller.dart';
import 'widgets/connection_status_line.dart';
import 'widgets/feature_tile.dart';
import 'widgets/offline_banner.dart';
import 'widgets/profile_chip.dart';
import 'widgets/tip_card.dart';

/// Page d'accueil : profil, état de la connexion, conseil du jour et accès aux
/// quatre fonctionnalités.
///
/// L'écran ne contient aucun état : il lit celui des contrôleurs placés
/// au-dessus de lui et se reconstruit quand ils changent.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Change d'onglet. `read` suffit : on déclenche une action en réponse à un
  /// appui, on n'a pas besoin d'écouter le contrôleur.
  void _open(BuildContext context, AppTab tab) {
    context.read<NavigationController>().goTo(tab);
  }

  @override
  Widget build(BuildContext context) {
    // `select` : l'accueil ne se reconstruit que si le profil change.
    final profile = context.select<AppController, InvestorProfileType?>(
      (app) => app.profile,
    );
    // `watch` : l'accueil se reconstruit à chaque changement de connexion.
    final connectivity = context.watch<ConnectivityController>();

    final now = DateTime.now();
    final tip = tipOfTheDay(date: now, profile: profile);

    return SafeArea(
      bottom: false,
      // Tirer l'écran vers le bas relance la vérification de la connexion.
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: connectivity.check,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${greetingFor(now)},',
                    style: AppTextStyles.bodyMuted,
                  ),
                ),
                const SizedBox(width: 12),
                ProfileChip(
                  profile: profile,
                  onTap: () => _open(context, AppTab.profile),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text('Par où commencer\u00A0?', style: AppTextStyles.title),
            const SizedBox(height: 10),
            ConnectionStatusLine(
              status: connectivity.status,
              lastCheckedAt: connectivity.lastCheckedAt,
              isRefreshing: connectivity.isRefreshing,
            ),
            if (connectivity.status == ConnectionStatus.offline) ...[
              const SizedBox(height: 12),
              OfflineBanner(onRetry: connectivity.check),
            ],
            const SizedBox(height: 16),
            TipCard(
              tip: tip,
              profile: profile,
              onTap: () => _open(context, AppTab.learn),
            ),
            const SizedBox(height: 16),
            // IntrinsicHeight : les deux tuiles d'une ligne ont la même
            // hauteur, celle de la plus haute.
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: FeatureTile(
                      icon: Icons.calculate_outlined,
                      title: 'Intérêts composés',
                      subtitle: 'Capital, versements, taux, durée',
                      badge: const StatusBadge(
                        label: 'Hors ligne',
                        icon: Icons.check,
                        tone: BadgeTone.positive,
                      ),
                      onTap: () => _open(context, AppTab.calculator),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FeatureTile(
                      icon: Icons.show_chart,
                      title: 'Simuler un ETF ou une action',
                      subtitle: 'Et si j’avais investi…\u00A0?',
                      badge: const StatusBadge(
                        label: 'En ligne',
                        icon: Icons.wifi,
                        tone: BadgeTone.info,
                      ),
                      onTap: () => _open(context, AppTab.calculator),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: FeatureTile(
                      icon: Icons.menu_book_outlined,
                      title: 'Apprendre',
                      subtitle: 'ETF, actions, PEA, PEL…',
                      badge: const StatusBadge(
                        label: 'Hors ligne',
                        icon: Icons.check,
                        tone: BadgeTone.positive,
                      ),
                      onTap: () => _open(context, AppTab.learn),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FeatureTile(
                      icon: Icons.bookmark_border,
                      title: 'Mes simulations',
                      subtitle: 'Retrouvez vos calculs',
                      badge: const StatusBadge(
                        label: 'Sur le téléphone',
                        icon: Icons.smartphone,
                      ),
                      onTap: () => _open(context, AppTab.simulations),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
