import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Carte de l'application : fond blanc, coins arrondis et filet gris.
///
/// Avec [onTap], toute la carte est cliquable et réagit à l'appui.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Material + InkWell : l'effet d'appui est dessiné sur le fond de la carte
    // et reste dans ses coins arrondis.
    return Material(
      color: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        side: BorderSide(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
