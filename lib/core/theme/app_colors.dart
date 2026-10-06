import 'package:flutter/material.dart';

/// Palette de l'application, reprise des maquettes.
class AppColors {
  AppColors._();

  // Fonds et texte
  static const Color background = Color(0xFFF4F2EC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF15201B);
  static const Color muted = Color(0xFF56615B);
  static const Color line = Color(0xFFE2DED3);

  // Couleur principale (vert)
  static const Color primary = Color(0xFF1D5C47);
  static const Color primarySoft = Color(0xFFE1EEE7);
  static const Color primaryInk = Color(0xFF0F3A2C);

  /// Texte secondaire posé sur un fond [primary].
  static const Color onPrimaryMuted = Color(0xFFCFE6DA);

  // Couleurs d'état
  static const Color warning = Color(0xFF8A4F0C);
  static const Color warningSoft = Color(0xFFFBEFD8);
  static const Color info = Color(0xFF2F4F86);
  static const Color infoSoft = Color(0xFFE4EAF5);
  static const Color danger = Color(0xFFA3312B);
  static const Color dangerSoft = Color(0xFFF8E3E1);
  static const Color neutralSoft = Color(0xFFECE9E1);

  // Graphiques
  static const Color chartNeutral = Color(0xFFB8C2BC);

  /// [primary] à 12 % d'opacité, pour la surface sous une courbe.
  static const Color chartFill = Color(0x1F1D5C47);
}
