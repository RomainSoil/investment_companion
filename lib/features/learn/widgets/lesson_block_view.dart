import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/lesson.dart';

/// Affiche un bloc de contenu d'une leçon.
///
/// Le `switch` porte sur une classe `sealed` : si on ajoute un type de bloc
/// sans l'afficher ici, le code ne compile plus.
class LessonBlockView extends StatelessWidget {
  const LessonBlockView({super.key, required this.block});

  final LessonBlock block;

  @override
  Widget build(BuildContext context) {
    return switch (block) {
      LessonHeading(:final text) => Text(text, style: AppTextStyles.heading),
      LessonParagraph(:final text) => Text(text, style: AppTextStyles.body),
      LessonBullets(:final items) => _Bullets(items: items),
      LessonNote(:final text) => _Note(text: text),
      final LessonComparison comparison => _Comparison(comparison: comparison),
    };
  }
}

class _Bullets extends StatelessWidget {
  const _Bullets({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 9, right: 10),
                  child: SizedBox(
                    width: 5,
                    height: 5,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                Expanded(child: Text(item, style: AppTextStyles.body)),
              ],
            ),
          ),
      ],
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.infoSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.info_outline, size: 18, color: AppColors.info),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body.copyWith(
                fontSize: 14,
                color: AppColors.info,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Comparison extends StatelessWidget {
  const _Comparison({required this.comparison});

  final LessonComparison comparison;

  static const TextStyle _cell = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 13,
    height: 1.35,
    color: AppColors.ink,
  );

  Widget _row(String label, List<String> values, {required bool header}) {
    final valueStyle = header ? AppTextStyles.overline : _cell;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: _cell.copyWith(
                color: AppColors.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          for (final value in values) ...[
            const SizedBox(width: 8),
            Expanded(flex: 5, child: Text(value, style: valueStyle)),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          _row('', comparison.columns, header: true),
          for (final row in comparison.rows) ...[
            const Divider(height: 1, color: AppColors.line),
            _row(row.label, row.values, header: false),
          ],
        ],
      ),
    );
  }
}
