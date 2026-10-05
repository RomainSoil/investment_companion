import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../state/connectivity_controller.dart';

/// Ligne qui affiche l'état de la connexion sur l'accueil.
///
/// À chaque état correspond un affichage : vérification en cours, en ligne,
/// hors connexion, avec l'heure de la dernière vérification.
class ConnectionStatusLine extends StatelessWidget {
  const ConnectionStatusLine({
    super.key,
    required this.status,
    required this.lastCheckedAt,
    required this.isRefreshing,
  });

  final ConnectionStatus status;
  final DateTime? lastCheckedAt;
  final bool isRefreshing;

  /// Précision ajoutée après l'état : actualisation en cours, ou heure de la
  /// dernière vérification.
  String get _detail {
    final checkedAt = lastCheckedAt;
    if (isRefreshing) {
      return ' · actualisation…';
    }
    if (checkedAt == null) {
      return '';
    }
    return ' · vérifié à ${formatTime(checkedAt)}';
  }

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final String text;
    final Color color;

    switch (status) {
      case ConnectionStatus.checking:
        icon = Icons.sync;
        text = 'Vérification de la connexion…';
        color = AppColors.muted;
      case ConnectionStatus.online:
        icon = Icons.wifi;
        text = 'En ligne$_detail';
        color = AppColors.muted;
      case ConnectionStatus.offline:
        icon = Icons.wifi_off;
        text = 'Hors connexion$_detail';
        color = AppColors.warning;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Row(
        // Une clé par état : le passage d'un état à l'autre se fait en fondu.
        key: ValueKey<ConnectionStatus>(status),
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.caption.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
