import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/investor_profile.dart';

/// Pastille du profil investisseur, en haut de l'accueil.
///
/// Elle représente l'état métier « profil défini ou non » : elle affiche le
/// nom du profil, ou invite à le définir.
class ProfileChip extends StatelessWidget {
  const ProfileChip({super.key, required this.profile, required this.onTap});

  final InvestorProfileType? profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = profile?.label ?? 'Définir mon profil';

    return Material(
      color: AppColors.primarySoft,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          // 12 + 20 + 12 : la zone tactile fait au moins 44 de haut.
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.track_changes,
                size: 16,
                color: AppColors.primaryInk,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 13,
                  height: 1.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryInk,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
