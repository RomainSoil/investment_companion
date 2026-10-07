import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/navigation.dart';
import '../../core/widgets/status_badge.dart';
import '../../domain/daily_tip.dart';
import '../../domain/investor_profile.dart';
import '../../state/app_controller.dart';
import '../../state/connectivity_controller.dart';
import '../../state/lessons_controller.dart';
import '../../state/navigation_controller.dart';
import '../assets/asset_list_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    // `select` : l'accueil ne se reconstruit que si le profil change.
    final profile = context.select<AppController, InvestorProfileType?>(
      (app) => app.profile,
    );
    // `watch` : l'accueil se reconstruit à chaque changement de connexion.
    final connectivity = context.watch<ConnectivityController>();

    // Progression des leçons, affichée sur la tuile « Apprendre ».
    final lessonsDone = context.select<LessonsController, int>(
      (lessons) => lessons.doneCount,
    );
    final lessonsTotal = context.select<LessonsController, int>(
      (lessons) => lessons.totalCount,
    );

    // `read` suffit pour changer d'onglet : on réagit à un appui, on n'a pas
    // besoin d'écouter le contrôleur.
    void goTo(AppTab tab) => context.read<NavigationController>().goTo(tab);

    final now = DateTime.now();

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
                  onTap: () => goTo(AppTab.profile),
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
              tip: tipOfTheDay(date: now, profile: profile),
              profile: profile,
              onTap: () => goTo(AppTab.learn),
            ),
            const SizedBox(height: 16),
            _TileRow(
              FeatureTile(
                icon: Icons.calculate_outlined,
                title: 'Intérêts composés',
                subtitle: 'Capital, versements, taux, durée',
                badge: const StatusBadge(
                  label: 'Hors ligne',
                  icon: Icons.check,
                  tone: BadgeTone.positive,
                ),
                onTap: () => goTo(AppTab.calculator),
              ),
              FeatureTile(
                icon: Icons.show_chart,
                title: 'Simuler un ETF ou une action',
                subtitle: 'Et si j’avais investi…\u00A0?',
                badge: const StatusBadge(
                  label: 'En ligne',
                  icon: Icons.wifi,
                  tone: BadgeTone.info,
                ),
                onTap: () => openScreen(context, const AssetListScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _TileRow(
              FeatureTile(
                icon: Icons.menu_book_outlined,
                title: 'Apprendre',
                subtitle: 'ETF, actions, PEA, PEL…',
                badge: StatusBadge(
                  label: '$lessonsDone / $lessonsTotal leçons',
                  icon: Icons.check,
                  tone: BadgeTone.positive,
                ),
                onTap: () => goTo(AppTab.learn),
              ),
              FeatureTile(
                icon: Icons.bookmark_border,
                title: 'Mes simulations',
                subtitle: 'Retrouvez vos calculs',
                badge: const StatusBadge(
                  label: 'Sur le téléphone',
                  icon: Icons.smartphone,
                ),
                onTap: () => goTo(AppTab.simulations),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Deux tuiles côte à côte, de même largeur et de même hauteur.
class _TileRow extends StatelessWidget {
  const _TileRow(this.first, this.second);

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    // IntrinsicHeight : les deux tuiles prennent la hauteur de la plus haute.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: first),
          const SizedBox(width: 12),
          Expanded(child: second),
        ],
      ),
    );
  }
}
