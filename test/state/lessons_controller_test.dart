import 'package:flutter_test/flutter_test.dart';
import 'package:investment_companion/data/app_preferences.dart';
import 'package:investment_companion/domain/lesson.dart';
import 'package:investment_companion/state/lessons_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

Lesson lessonWith(String id, LessonCategory category) {
  return Lesson(
    id: id,
    title: 'Leçon $id',
    category: category,
    minutes: 1,
    blocks: const [LessonParagraph('texte')],
    keyPoints: const ['point'],
    quiz: const [],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final lessons = [
    lessonWith('a', LessonCategory.basics),
    lessonWith('b', LessonCategory.basics),
    lessonWith('c', LessonCategory.risk),
  ];

  Future<AppPreferences> preferencesWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return AppPreferences(await SharedPreferences.getInstance());
  }

  group('LessonsController', () {
    test('au départ, aucune leçon n’est commencée', () async {
      final controller = LessonsController(
        await preferencesWith({}),
        lessons: lessons,
      );

      expect(controller.totalCount, 3);
      expect(controller.doneCount, 0);
      expect(controller.progress, 0);
      expect(controller.statusOf('a'), LessonStatus.todo);
    });

    test('markStarted passe la leçon en cours et l’enregistre', () async {
      final preferences = await preferencesWith({});
      final controller = LessonsController(preferences, lessons: lessons);
      var notifications = 0;
      controller.addListener(() => notifications++);

      await controller.markStarted('a');
      await controller.markStarted('a');

      expect(controller.statusOf('a'), LessonStatus.inProgress);
      expect(notifications, 1);
      expect(preferences.lessonsStarted, {'a'});
    });

    test('markDone termine la leçon et fait avancer la progression', () async {
      final preferences = await preferencesWith({});
      final controller = LessonsController(preferences, lessons: lessons);

      await controller.markStarted('a');
      await controller.markDone('a');

      expect(controller.statusOf('a'), LessonStatus.done);
      expect(controller.doneCount, 1);
      expect(controller.progress, closeTo(1 / 3, 1e-9));
      expect(preferences.lessonsDone, {'a'});
    });

    test('une leçon terminée ne repasse pas en cours', () async {
      final controller = LessonsController(
        await preferencesWith({}),
        lessons: lessons,
      );

      await controller.markDone('a');
      await controller.markStarted('a');

      expect(controller.statusOf('a'), LessonStatus.done);
    });

    test('ignore une leçon qui n’existe pas', () async {
      final preferences = await preferencesWith({});
      final controller = LessonsController(preferences, lessons: lessons);

      await controller.markStarted('inconnue');
      await controller.markDone('inconnue');

      expect(controller.doneCount, 0);
      expect(preferences.lessonsStarted, isEmpty);
      expect(preferences.lessonsDone, isEmpty);
    });

    test('relit la progression enregistrée', () async {
      final controller = LessonsController(
        await preferencesWith({
          AppPreferences.lessonsStartedKey: <String>['b'],
          AppPreferences.lessonsDoneKey: <String>['a', 'ancienne'],
        }),
        lessons: lessons,
      );

      expect(controller.statusOf('a'), LessonStatus.done);
      expect(controller.statusOf('b'), LessonStatus.inProgress);
      // Une leçon retirée du catalogue ne compte plus.
      expect(controller.doneCount, 1);
    });

    test('lessonsIn filtre par thème', () async {
      final controller = LessonsController(
        await preferencesWith({}),
        lessons: lessons,
      );

      expect(controller.lessonsIn(null), hasLength(3));
      expect(
        controller.lessonsIn(LessonCategory.basics).map((l) => l.id),
        ['a', 'b'],
      );
      expect(controller.lessonsIn(LessonCategory.envelopes), isEmpty);
    });

    test('reset efface la progression', () async {
      final preferences = await preferencesWith({});
      final controller = LessonsController(preferences, lessons: lessons);
      await controller.markDone('a');

      await controller.reset();

      expect(controller.statusOf('a'), LessonStatus.todo);
      expect(preferences.lessonsDone, isEmpty);
    });
  });
}
