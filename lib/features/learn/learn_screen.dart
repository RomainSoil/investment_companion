import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/navigation.dart';
import '../../core/widgets/app_card.dart';
import '../../domain/lesson.dart';
import '../../state/lessons_controller.dart';
import 'lesson_screen.dart';
import 'widgets/lesson_tile.dart';

/// Onglet « Apprendre » : progression, filtre par thème et liste des leçons.
///
/// Le filtre choisi est un état local à cet écran : il reste dans ce
/// `StatefulWidget`. La progression, elle, vient de [LessonsController].
class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  /// Thème affiché, ou `null` pour tout afficher.
  LessonCategory? _filter;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LessonsController>();
    final categories =
        _filter == null ? LessonCategory.values : <LessonCategory>[_filter!];

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          const Text('Apprendre', style: AppTextStyles.title),
          const SizedBox(height: 8),
          const Text(
            'Des leçons courtes, avec un quiz à la fin. Toutes sont '
            'disponibles hors connexion.',
            style: AppTextStyles.bodyMuted,
          ),
          const SizedBox(height: 16),
          _ProgressCard(
            done: controller.doneCount,
            total: controller.totalCount,
            progress: controller.progress,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Tout'),
                selected: _filter == null,
                onSelected: (_) => setState(() => _filter = null),
              ),
              for (final category in LessonCategory.values)
                ChoiceChip(
                  label: Text(category.label),
                  selected: _filter == category,
                  onSelected: (_) => setState(() => _filter = category),
                ),
            ],
          ),
          for (final category in categories) ...[
            const SizedBox(height: 20),
            Text(category.label.toUpperCase(), style: AppTextStyles.overline),
            const SizedBox(height: 4),
            for (final lesson in controller.lessonsIn(category))
              LessonTile(
                lesson: lesson,
                status: controller.statusOf(lesson.id),
                onTap: () => openScreen(context, LessonScreen(lesson: lesson)),
              ),
          ],
        ],
      ),
    );
  }
}

/// Carte de progression. La barre s'anime quand une leçon est terminée.
class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.done,
    required this.total,
    required this.progress,
  });

  final int done;
  final int total;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Votre parcours', style: AppTextStyles.label),
              ),
              Text('$done / $total leçons', style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            // Animation implicite : la barre glisse de l'ancienne valeur à
            // la nouvelle.
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: AppColors.line,
                  color: AppColors.primary,
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.download_done,
                size: 15,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Contenu enregistré sur le téléphone',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
