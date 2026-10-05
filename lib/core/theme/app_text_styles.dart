import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Noms des familles de polices déclarées dans `pubspec.yaml`.
class AppFonts {
  AppFonts._();

  /// Texte courant.
  static const String body = 'DMSans';

  /// Titres.
  static const String display = 'Fraunces';
}

/// Styles de texte communs à toute l'application.
class AppTextStyles {
  AppTextStyles._();

  /// Grand titre de l'écran de bienvenue.
  static const TextStyle display = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 34,
    height: 1.15,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  /// Titre d'un écran.
  static const TextStyle title = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 28,
    height: 1.15,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  /// Titre d'une carte.
  static const TextStyle heading = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 20,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  static const TextStyle body = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 15,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.ink,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 15,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
  );

  /// Libellé en gras (titre de tuile, lien).
  static const TextStyle label = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 15,
    height: 1.3,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 13,
    height: 1.4,
    fontWeight: FontWeight.w500,
    color: AppColors.muted,
  );

  /// Petit sur-titre en capitales.
  static const TextStyle overline = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: AppColors.muted,
  );
}
