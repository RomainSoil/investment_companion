import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Bandeau affiché sur l'accueil quand le téléphone est hors connexion.
///
/// Il dit ce qui reste utilisable et propose de relancer la vérification.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
      decoration: BoxDecoration(
        color: AppColors.warningSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, size: 18, color: AppColors.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Hors connexion. Le calculateur d’intérêts composés et les '
              'leçons restent disponibles.',
              style: AppTextStyles.caption.copyWith(color: AppColors.warning),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(foregroundColor: AppColors.warning),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}
