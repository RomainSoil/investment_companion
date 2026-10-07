import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/status_badge.dart';
import '../../domain/lesson.dart';
import '../../state/lessons_controller.dart';
import 'widgets/key_points_card.dart';
import 'widgets/lesson_block_view.dart';
import 'widgets/quiz_question_card.dart';

/// Écran d'une leçon : contenu, points à retenir, quiz, puis bouton pour la
/// terminer.
class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key, required this.lesson});

  final Lesson lesson;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  @override
  void initState() {
    super.initState();
    // Ouvrir la leçon la fait passer « en cours ». On attend la fin de la
    // première image : on ne doit pas modifier un contrôleur pendant que
    // l'écran se construit.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<LessonsController>().markStarted(widget.lesson.id);
      }
    });
  }

  void _finish() {
    context.read<LessonsController>().markDone(widget.lesson.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final done = context.select<LessonsController, bool>(
      (controller) => controller.statusOf(lesson.id) == LessonStatus.done,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Leçon')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            // Wrap : la seconde pastille passe à la ligne si la place manque.
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                StatusBadge(
                  label: '${lesson.category.label} · ${lesson.minutes} min',
                ),
                if (done)
                  const StatusBadge(
                    label: 'Terminée',
                    icon: Icons.check,
                    tone: BadgeTone.positive,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(lesson.title, style: AppTextStyles.title),
            const SizedBox(height: 16),
            for (final block in lesson.blocks)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: LessonBlockView(block: block),
              ),
            const SizedBox(height: 4),
            KeyPointsCard(points: lesson.keyPoints),
            const SizedBox(height: 24),
            const Text('Quiz', style: AppTextStyles.heading),
            const SizedBox(height: 10),
            for (final question in lesson.quiz)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: QuizQuestionCard(question: question),
              ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _finish,
              child: Text(done ? 'Fermer la leçon' : 'J’ai terminé la leçon'),
            ),
          ],
        ),
      ),
    );
  }
}
