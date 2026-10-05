import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Couleurs possibles d'une pastille.
enum BadgeTone {
  positive(AppColors.primary, AppColors.primarySoft),
  info(AppColors.info, AppColors.infoSoft),
  neutral(AppColors.muted, AppColors.neutralSoft),
  warning(AppColors.warning, AppColors.warningSoft);

  const BadgeTone(this.foreground, this.background);

  final Color foreground;
  final Color background;
}

/// Petite pastille d'information, par exemple « Hors ligne ».
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.icon,
    this.tone = BadgeTone.neutral,
  });

  final String label;
  final IconData? icon;
  final BadgeTone tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: tone.foreground),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: tone.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
