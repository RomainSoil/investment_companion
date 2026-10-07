import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../domain/lesson.dart';

/// Icône associée à chaque thème de leçon.
IconData _iconFor(LessonCategory category) {
  return switch (category) {
    LessonCategory.basics => Icons.layers_outlined,
    LessonCategory.envelopes => Icons.shield_outlined,
    LessonCategory.risk => Icons.show_chart,
  };
}

/// Ligne d'une leçon dans la liste, avec son avancement à droite.
class LessonTile extends StatelessWidget {
  const LessonTile({
    super.key,
    required this.lesson,
    required this.status,
    required this.onTap,
  });

  final Lesson lesson;
  final LessonStatus status;
  final VoidCallback onTap;

  /// À chaque état de la leçon correspond un affichage.
  Widget _trailing() {
    return switch (status) {
      LessonStatus.done => Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, size: 16, color: Colors.white),
        ),
      LessonStatus.inProgress =>
        const StatusBadge(label: 'En cours', tone: BadgeTone.info),
      LessonStatus.todo =>
        const Icon(Icons.chevron_right, color: AppColors.muted),
    };
  }

  @override
  Widget build(BuildContext context) {
    final questions = lesson.quiz.length;
    final quizLabel = questions > 1 ? '$questions questions' : '1 question';

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.line)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _iconFor(lesson.category),
                size: 20,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lesson.title, style: AppTextStyles.label),
                  const SizedBox(height: 2),
                  Text(
                    '${lesson.minutes} min · $quizLabel',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _trailing(),
          ],
        ),
      ),
    );
  }
}
