import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../domain/lesson.dart';

/// Une question du quiz.
///
/// La réponse choisie est un état local : elle reste dans ce
/// `StatefulWidget` et disparaît quand on quitte la leçon.
class QuizQuestionCard extends StatefulWidget {
  const QuizQuestionCard({super.key, required this.question});

  final QuizQuestion question;

  @override
  State<QuizQuestionCard> createState() => _QuizQuestionCardState();
}

class _QuizQuestionCardState extends State<QuizQuestionCard> {
  /// Position de la réponse choisie, ou `null` tant qu'on n'a pas répondu.
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final question = widget.question;
    final selected = _selected;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(question.question, style: AppTextStyles.label),
          const SizedBox(height: 10),
          for (var index = 0; index < question.options.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _Option(
                text: question.options[index],
                state: _stateOf(index),
                onTap: () => setState(() => _selected = index),
              ),
            ),
          if (selected != null) ...[
            const SizedBox(height: 2),
            Text(
              question.isCorrect(selected)
                  ? 'Bonne réponse.'
                  : 'Ce n’est pas la bonne réponse.',
              style: AppTextStyles.label.copyWith(
                fontSize: 14,
                color: question.isCorrect(selected)
                    ? AppColors.primary
                    : AppColors.danger,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              question.explanation,
              style: AppTextStyles.bodyMuted.copyWith(fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  _OptionState _stateOf(int index) {
    final selected = _selected;
    if (selected == null) {
      return _OptionState.idle;
    }
    // Une fois la réponse donnée, la bonne réponse est toujours montrée.
    if (widget.question.isCorrect(index)) {
      return _OptionState.correct;
    }
    return index == selected ? _OptionState.wrong : _OptionState.idle;
  }
}

enum _OptionState { idle, correct, wrong }

class _Option extends StatelessWidget {
  const _Option({required this.text, required this.state, required this.onTap});

  final String text;
  final _OptionState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (background, border, icon, iconColor) = switch (state) {
      _OptionState.idle => (
          AppColors.surface,
          AppColors.line,
          Icons.radio_button_unchecked,
          AppColors.chartNeutral,
        ),
      _OptionState.correct => (
          AppColors.primarySoft,
          AppColors.primary,
          Icons.check_circle,
          AppColors.primary,
        ),
      _OptionState.wrong => (
          AppColors.dangerSoft,
          AppColors.danger,
          Icons.cancel,
          AppColors.danger,
        ),
    };

    return Material(
      color: background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 10),
              Expanded(child: Text(text, style: AppTextStyles.body)),
            ],
          ),
        ),
      ),
    );
  }
}
