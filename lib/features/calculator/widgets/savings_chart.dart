import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/savings_simulation.dart';

/// Couleur de la part versée dans le graphique et sa légende.
const Color investedColor = AppColors.chartNeutral;

/// Couleur des gains dans le graphique et sa légende.
const Color gainsColor = AppColors.primary;

/// Évolution d'un placement : la surface grise est la somme versée, la
/// surface verte au-dessus, les gains. La hauteur totale est la valeur.
class SavingsChart extends StatelessWidget {
  const SavingsChart({super.key, required this.points});

  final List<SavingsPoint> points;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Graphique : part versée et part des gains au fil du temps',
      child: CustomPaint(
        painter: _SavingsChartPainter(points),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _SavingsChartPainter extends CustomPainter {
  _SavingsChartPainter(this.points);

  final List<SavingsPoint> points;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) {
      return;
    }

    final top = points
        .map((point) => math.max(point.value, point.invested))
        .reduce(math.max);
    // Rien de versé ni gagné : pas d'échelle possible.
    if (top <= 0) {
      return;
    }

    Offset pointAt(int index, double amount) {
      return Offset(
        size.width * index / (points.length - 1),
        size.height * (1 - amount / top),
      );
    }

    /// Surface comprise entre le bas du graphique et la courbe [amountOf].
    Path areaUnder(double Function(SavingsPoint point) amountOf) {
      final path = Path()..moveTo(0, size.height);
      for (var i = 0; i < points.length; i++) {
        final point = pointAt(i, amountOf(points[i]));
        path.lineTo(point.dx, point.dy);
      }
      return path
        ..lineTo(size.width, size.height)
        ..close();
    }

    // La valeur d'abord, puis la somme versée par-dessus : seule la partie
    // de la valeur qui dépasse la somme versée (les gains) reste visible.
    canvas.drawPath(
      areaUnder((point) => point.value),
      Paint()..color = gainsColor,
    );
    canvas.drawPath(
      areaUnder((point) => point.invested),
      Paint()..color = investedColor,
    );

    // En cas de perte, la valeur passe sous la somme versée : on trace sa
    // courbe pour qu'elle reste visible.
    final valueLine = Path();
    for (var i = 0; i < points.length; i++) {
      final point = pointAt(i, points[i].value);
      if (i == 0) {
        valueLine.moveTo(point.dx, point.dy);
      } else {
        valueLine.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(
      valueLine,
      Paint()
        ..color = gainsColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_SavingsChartPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
