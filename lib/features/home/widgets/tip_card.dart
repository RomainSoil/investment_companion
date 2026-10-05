import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/daily_tip.dart';
import '../../../domain/investor_profile.dart';

/// Carte « Conseil du jour » de l'accueil.
class TipCard extends StatelessWidget {
  const TipCard({
    super.key,
    required this.tip,
    required this.profile,
    required this.onTap,
  });

  final DailyTip tip;

  /// Profil de l'utilisateur, rappelé dans le sur-titre s'il est défini.
  final InvestorProfileType? profile;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final currentProfile = profile;
    final overline = currentProfile == null
        ? 'CONSEIL DU JOUR'
        : 'CONSEIL DU JOUR · PROFIL ${currentProfile.label.toUpperCase()}';

    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    size: 15,
                    color: AppColors.onPrimaryMuted,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      overline,
                      style: AppTextStyles.overline.copyWith(
                        color: AppColors.onPrimaryMuted,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                tip.text,
                style: AppTextStyles.heading.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      tip.linkLabel,
                      style: AppTextStyles.label.copyWith(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
