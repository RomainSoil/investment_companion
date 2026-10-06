import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/price_history.dart';

/// Courbe des cours de clôture, du plus ancien (à gauche) au plus récent.
class PriceChart extends StatelessWidget {
  const PriceChart({super.key, required this.points});

  final List<PricePoint> points;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Graphique de l’évolution des cours',
      child: CustomPaint(
        painter: _PriceChartPainter(points),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _PriceChartPainter extends CustomPainter {
  _PriceChartPainter(this.points);

  final List<PricePoint> points;

  @override
  void paint(Canvas canvas, Size size) {
    // Lignes de repère horizontales.
    final gridPaint = Paint()
      ..color = AppColors.line
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (points.length < 2) {
      return;
    }

    final closes = points.map((point) => point.close);
    final low = closes.reduce(math.min);
    final high = closes.reduce(math.max);
    // Un cours constant donnerait une échelle nulle.
    final range = high == low ? 1.0 : high - low;

    Offset pointAt(int index) {
      return Offset(
        size.width * index / (points.length - 1),
        size.height * (1 - (points[index].close - low) / range),
      );
    }

    final start = pointAt(0);
    final path = Path()..moveTo(start.dx, start.dy);
    for (var i = 1; i < points.length; i++) {
      final point = pointAt(i);
      path.lineTo(point.dx, point.dy);
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_PriceChartPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
