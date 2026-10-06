import 'investor_profile.dart';

/// Une réponse possible : plus elle traduit de goût pour le risque, plus elle
/// rapporte de points.
class Answer {
  const Answer(this.label, this.points);

  final String label;
  final int points;
}

/// Une question du questionnaire et ses réponses possibles.
class Question {
  const Question(this.text, this.answers);

  final String text;
  final List<Answer> answers;
}

/// Questionnaire de profil investisseur : chaque réponse vaut de 0 à 2
/// points, pour un score total de 0 à 10.
const List<Question> profileQuestionnaire = [
  Question(
    'Dans combien de temps pensez-vous avoir besoin de cet argent\u00A0?',
    [
      Answer('Dans moins de 3 ans', 0),
      Answer('Dans 3 à 8 ans', 1),
      Answer('Dans plus de 8 ans', 2),
    ],
  ),
  Question(
    'Quel est votre objectif principal\u00A0?',
    [
      Answer('Protéger mon épargne', 0),
      Answer('La faire croître régulièrement', 1),
      Answer('Rechercher la plus forte croissance', 2),
    ],
  ),
  Question(
    'Votre placement perd 20\u00A0% en quelques mois. Que faites-vous\u00A0?',
    [
      Answer('Je vends tout pour limiter la perte', 0),
      Answer('J’attends que le cours remonte', 1),
      Answer('J’en profite pour investir davantage', 2),
    ],
  ),
  Question(
    'Avez-vous déjà investi en bourse\u00A0?',
    [
      Answer('Jamais', 0),
      Answer('Un peu, par exemple via un ETF', 1),
      Answer('Oui, régulièrement', 2),
    ],
  ),
  Question(
    'Avez-vous une épargne de précaution, disponible à tout moment\u00A0?',
    [
      Answer('Non', 0),
      Answer('Oui, moins de 3 mois de dépenses', 1),
      Answer('Oui, plus de 3 mois de dépenses', 2),
    ],
  ),
];

/// Profil correspondant au [score] total du questionnaire (0 à 10).
InvestorProfileType profileForScore(int score) {
  if (score <= 3) {
    return InvestorProfileType.prudent;
  }
  if (score <= 6) {
    return InvestorProfileType.equilibre;
  }
  return InvestorProfileType.dynamique;
}
