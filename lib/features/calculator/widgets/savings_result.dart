import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/savings_simulation.dart';
import 'savings_chart.dart';

/// Résultat d'une simulation : valeur finale, part versée et part des gains,
/// et leur évolution dans le temps.
class SavingsResult extends StatelessWidget {
  const SavingsResult({
    super.key,
    required this.points,
    required this.currency,
  });

  final List<SavingsPoint> points;

  /// Devise affichée après les montants, par exemple « € » ou « USD ».
  final String currency;

  @override
  Widget build(BuildContext context) {
    final last = points.last;
    final hasLoss = last.gains < 0;

    // Proportions par rapport à la valeur finale.
    String share(double amount) {
      return last.value > 0
          ? ' (${(amount / last.value * 100).round()}\u00A0%)'
          : '';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Valeur finale', style: AppTextStyles.caption),
        Text(
          formatPrice(last.value, currency),
          style: AppTextStyles.title,
        ),
        const SizedBox(height: 12),
        _LegendRow(
          color: investedColor,
          label: 'Versé',
          value: '${formatPrice(last.invested, currency)}'
              '${hasLoss ? '' : share(last.invested)}',
        ),
        _LegendRow(
          color: hasLoss ? AppColors.danger : gainsColor,
          label: hasLoss ? 'Pertes' : 'Gains',
          value: '${formatPrice(last.gains, currency)}'
              '${hasLoss ? '' : share(last.gains)}',
        ),
        const SizedBox(height: 16),
        SizedBox(height: 200, child: SavingsChart(points: points)),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(formatDate(points.first.date), style: AppTextStyles.caption),
            Text(formatDate(last.date), style: AppTextStyles.caption),
          ],
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: AppTextStyles.bodyMuted)),
          Text(value, style: AppTextStyles.label),
        ],
      ),
    );
  }
}
