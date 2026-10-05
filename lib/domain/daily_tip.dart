import 'investor_profile.dart';

/// Un conseil pédagogique affiché sur l'accueil.
class DailyTip {
  const DailyTip({
    required this.text,
    this.linkLabel = 'Comprendre en 3 min',
    this.profiles,
  });

  final String text;

  /// Texte du lien vers la leçon correspondante.
  final String linkLabel;

  /// Profils auxquels le conseil s'adresse. `null` : conseil valable pour tous.
  final List<InvestorProfileType>? profiles;

  /// Vrai si le conseil peut être montré à un utilisateur ayant ce [profile]
  /// (ou n'ayant pas encore de profil, si [profile] vaut `null`).
  bool suits(InvestorProfileType? profile) {
    final allowed = profiles;
    if (allowed == null) {
      return true;
    }
    return profile != null && allowed.contains(profile);
  }
}

/// Conseils embarqués dans l'application : disponibles hors connexion.
const List<DailyTip> dailyTips = [
  DailyTip(text: 'Diversifier, c’est ne pas dépendre d’une seule entreprise.'),
  DailyTip(
    text: 'Avant d’investir, gardez de côté une épargne de précaution.',
  ),
  DailyTip(
    text:
        'Investir un petit montant chaque mois évite de chercher le «\u00A0bon moment\u00A0».',
  ),
  DailyTip(
    text:
        'Plus votre horizon est long, plus vous pouvez traverser des baisses temporaires.',
  ),
  DailyTip(
    text: 'Les performances passées ne garantissent pas les performances futures.',
  ),
  DailyTip(
    text:
        'Regardez les frais\u00A0: sur vingt ans, un point de frais par an pèse lourd sur le résultat.',
  ),
  DailyTip(
    text:
        'Un profil prudent privilégie des placements dont la valeur varie peu.',
    profiles: [InvestorProfileType.prudent],
  ),
  DailyTip(
    text:
        'Un profil équilibré partage son épargne entre placements stables et placements plus risqués.',
    profiles: [InvestorProfileType.equilibre],
  ),
  DailyTip(
    text:
        'Un profil dynamique accepte de fortes variations en échange d’un potentiel plus élevé.',
    profiles: [InvestorProfileType.dynamique],
  ),
];

/// Choisit le conseil du jour.
///
/// Le choix ne dépend que de la [date] et du [profile] : le même jour,
/// l'utilisateur voit toujours le même conseil, et le conseil change le
/// lendemain.
DailyTip tipOfTheDay({
  required DateTime date,
  InvestorProfileType? profile,
  List<DailyTip> tips = dailyTips,
}) {
  assert(tips.isNotEmpty, 'Il faut au moins un conseil.');

  final suitable = tips.where((tip) => tip.suits(profile)).toList();
  final pool = suitable.isEmpty ? tips : suitable;

  // Numéro du jour, compté depuis une date fixe (en UTC pour ignorer les
  // changements d'heure).
  final day = DateTime.utc(date.year, date.month, date.day);
  final dayNumber = day.difference(DateTime.utc(2024)).inDays;

  return pool[dayNumber % pool.length];
}
