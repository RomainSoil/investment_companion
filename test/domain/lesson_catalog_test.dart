import 'package:flutter_test/flutter_test.dart';
import 'package:investment_companion/domain/lesson_catalog.dart';
import 'package:investment_companion/domain/lesson.dart';

void main() {
  group('lessonCatalog', () {
    test('donne à chaque leçon un identifiant unique', () {
      final ids = lessonCatalog.map((lesson) => lesson.id).toSet();

      expect(ids, hasLength(lessonCatalog.length));
    });

    test('couvre tous les thèmes', () {
      final categories = lessonCatalog.map((lesson) => lesson.category).toSet();

      expect(categories, LessonCategory.values.toSet());
    });

    test('renseigne le contenu, les points à retenir et le quiz', () {
      for (final lesson in lessonCatalog) {
        expect(lesson.title.trim(), isNotEmpty, reason: lesson.id);
        expect(lesson.minutes, greaterThan(0), reason: lesson.id);
        expect(lesson.blocks, isNotEmpty, reason: lesson.id);
        expect(lesson.keyPoints, isNotEmpty, reason: lesson.id);
        expect(lesson.quiz, isNotEmpty, reason: lesson.id);
      }
    });

    test('désigne dans chaque question une bonne réponse qui existe', () {
      for (final lesson in lessonCatalog) {
        for (final question in lesson.quiz) {
          expect(question.options.length, greaterThanOrEqualTo(2),
              reason: lesson.id);
          expect(
            question.correctIndex,
            inInclusiveRange(0, question.options.length - 1),
            reason: lesson.id,
          );
          expect(question.explanation.trim(), isNotEmpty, reason: lesson.id);
        }
      }
    });

    test('donne autant de valeurs que de colonnes dans les comparatifs', () {
      for (final lesson in lessonCatalog) {
        for (final block in lesson.blocks.whereType<LessonComparison>()) {
          for (final row in block.rows) {
            expect(row.values, hasLength(block.columns.length),
                reason: '${lesson.id} : ${row.label}');
          }
        }
      }
    });
  });

  test('QuizQuestion.isCorrect ne reconnaît que la bonne réponse', () {
    const question = QuizQuestion(
      question: 'q',
      options: ['a', 'b', 'c'],
      correctIndex: 2,
      explanation: 'e',
    );

    expect(question.isCorrect(2), isTrue);
    expect(question.isCorrect(0), isFalse);
  });
}
