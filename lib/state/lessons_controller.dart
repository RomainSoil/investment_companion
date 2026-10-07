import 'package:flutter/foundation.dart';

import '../data/app_preferences.dart';
import '../domain/lesson.dart';
import '../domain/lesson_catalog.dart';

/// Leçons et progression de l'utilisateur.
///
/// La progression est un état partagé : la liste des leçons, l'écran d'une
/// leçon et l'accueil l'affichent tous les trois. Elle est enregistrée sur le
/// téléphone à chaque changement.
class LessonsController extends ChangeNotifier {
  LessonsController(
    this._preferences, {
    List<Lesson> lessons = lessonCatalog,
  })  : _lessons = lessons,
        _started = _preferences.lessonsStarted,
        _done = _preferences.lessonsDone;

  final AppPreferences _preferences;
  final List<Lesson> _lessons;
  final Set<String> _started;
  final Set<String> _done;

  List<Lesson> get lessons => _lessons;

  int get totalCount => _lessons.length;

  /// Nombre de leçons terminées, parmi celles qui existent encore.
  int get doneCount {
    return _lessons.where((lesson) => _done.contains(lesson.id)).length;
  }

  /// Part des leçons terminées, entre 0 et 1.
  double get progress => totalCount == 0 ? 0 : doneCount / totalCount;

  LessonStatus statusOf(String lessonId) {
    if (_done.contains(lessonId)) {
      return LessonStatus.done;
    }
    if (_started.contains(lessonId)) {
      return LessonStatus.inProgress;
    }
    return LessonStatus.todo;
  }

  /// Leçons d'une catégorie, ou toutes si [category] vaut `null`.
  List<Lesson> lessonsIn(LessonCategory? category) {
    if (category == null) {
      return _lessons;
    }
    return _lessons.where((lesson) => lesson.category == category).toList();
  }

  bool _exists(String lessonId) {
    return _lessons.any((lesson) => lesson.id == lessonId);
  }

  /// L'utilisateur ouvre une leçon : elle passe « en cours », sauf si elle
  /// est déjà commencée ou terminée.
  Future<void> markStarted(String lessonId) async {
    if (!_exists(lessonId) || statusOf(lessonId) != LessonStatus.todo) {
      return;
    }
    _started.add(lessonId);
    notifyListeners();
    await _preferences.setLessonsStarted(_started);
  }

  /// L'utilisateur termine une leçon.
  Future<void> markDone(String lessonId) async {
    if (!_exists(lessonId) || _done.contains(lessonId)) {
      return;
    }
    _done.add(lessonId);
    notifyListeners();
    await _preferences.setLessonsDone(_done);
  }

  /// Efface toute la progression.
  Future<void> reset() async {
    if (_started.isEmpty && _done.isEmpty) {
      return;
    }
    _started.clear();
    _done.clear();
    notifyListeners();
    await _preferences.setLessonsStarted(_started);
    await _preferences.setLessonsDone(_done);
  }
}
