/// Thème d'une leçon, utilisé pour regrouper et filtrer la liste.
enum LessonCategory {
  basics('Les bases'),
  envelopes('Enveloppes'),
  risk('Risque');

  const LessonCategory(this.label);

  final String label;
}

/// Avancement d'une leçon pour l'utilisateur.
enum LessonStatus { todo, inProgress, done }

/// Un élément du contenu d'une leçon.
///
/// La classe est `sealed` : la liste des types de blocs est fermée, et
/// l'écran qui les affiche est obligé de tous les traiter.
sealed class LessonBlock {
  const LessonBlock();
}

/// Intertitre.
class LessonHeading extends LessonBlock {
  const LessonHeading(this.text);

  final String text;
}

/// Paragraphe de texte.
class LessonParagraph extends LessonBlock {
  const LessonParagraph(this.text);

  final String text;
}

/// Liste à puces.
class LessonBullets extends LessonBlock {
  const LessonBullets(this.items);

  final List<String> items;
}

/// Encadré : exemple chiffré ou mise en garde.
class LessonNote extends LessonBlock {
  const LessonNote(this.text);

  final String text;
}

/// Tableau comparatif : une colonne de critères, puis une colonne par élément
/// comparé.
class LessonComparison extends LessonBlock {
  const LessonComparison({required this.columns, required this.rows});

  /// Titres des colonnes comparées (sans la colonne des critères).
  final List<String> columns;

  final List<ComparisonRow> rows;
}

class ComparisonRow {
  const ComparisonRow(this.label, this.values);

  /// Critère comparé.
  final String label;

  /// Une valeur par colonne de [LessonComparison.columns].
  final List<String> values;
}

/// Question à choix unique posée à la fin d'une leçon.
class QuizQuestion {
  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String question;
  final List<String> options;

  /// Position de la bonne réponse dans [options].
  final int correctIndex;

  /// Explication affichée après la réponse.
  final String explanation;

  bool isCorrect(int index) => index == correctIndex;
}

/// Une leçon : son contenu, ses points à retenir et son quiz.
class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.category,
    required this.minutes,
    required this.blocks,
    required this.keyPoints,
    required this.quiz,
  });

  /// Identifiant stable, enregistré pour suivre la progression.
  final String id;

  final String title;
  final LessonCategory category;

  /// Durée de lecture estimée.
  final int minutes;

  final List<LessonBlock> blocks;
  final List<String> keyPoints;
  final List<QuizQuestion> quiz;
}
