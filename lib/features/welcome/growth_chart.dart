import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Courbe d'illustration de l'écran de bienvenue : la valeur d'un placement
/// régulier (trait plein) s'écarte peu à peu du montant versé (pointillés).
///
/// Animation codée : un [AnimationController] fait passer une progression de
/// 0 à 1, et le dessin (voir [GrowthChartPainter]) ne révèle que la partie de
/// la courbe correspondant à cette progression.
class GrowthChart extends StatefulWidget {
  const GrowthChart({super.key});

  @override
  State<GrowthChart> createState() => _GrowthChartState();
}

class _GrowthChartState extends State<GrowthChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    // La courbe démarre vite puis ralentit en arrivant au bout.
    _progress = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _progress.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Graphique : la valeur d’un placement régulier dépasse peu à peu le montant versé.',
      child: AnimatedBuilder(
        animation: _progress,
        builder: (context, child) {
          return CustomPaint(
            painter: GrowthChartPainter(progress: _progress.value),
            child: child,
          );
        },
        // Occupe toute la place disponible ; n'est pas reconstruit à chaque
        // image de l'animation.
        child: const SizedBox.expand(),
      ),
    );
  }
}

/// Dessine la courbe jusqu'à la fraction [progress] de sa largeur (0 à 1).
class GrowthChartPainter extends CustomPainter {
  GrowthChartPainter({required this.progress});

  final double progress;

  static const int _steps = 24;

  /// Montant versé : 100 au départ, puis 60 à chaque période.
  static double _invested(int step) => 100 + 60.0 * step;

  /// Valeur du placement si chaque versement rapporte 0,6 % par période.
  /// Ce sont des valeurs d'illustration, pas des données de marché.
  static double _value(int step) {
    const growth = 1.006;
    final factor = math.pow(growth, step).toDouble();
    return 100 * factor + 60 * (factor - 1) / (growth - 1);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final maxValue = _value(_steps) * 1.08;

    Offset pointFor(int step, double amount) {
      return Offset(
        size.width * step / _steps,
        size.height * (1 - amount / maxValue),
      );
    }

    // Lignes de repère horizontales.
    final gridPaint = Paint()
      ..color = AppColors.line
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Courbe de la valeur du placement.
    final start = pointFor(0, _value(0));
    final valuePath = Path()..moveTo(start.dx, start.dy);
    for (var step = 1; step <= _steps; step++) {
      final point = pointFor(step, _value(step));
      valuePath.lineTo(point.dx, point.dy);
    }

    // Le montant versé augmente régulièrement : c'est une droite.
    final investedStart = pointFor(0, _invested(0));
    final investedEnd = pointFor(_steps, _invested(_steps));

    // Surface comprise entre la courbe et la droite : les gains.
    final gainsPath = Path.from(valuePath)
      ..lineTo(investedEnd.dx, investedEnd.dy)
      ..lineTo(investedStart.dx, investedStart.dy)
      ..close();

    // On ne laisse apparaître que la partie gauche du dessin, sur une largeur
    // proportionnelle à la progression de l'animation.
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width * progress, size.height));

    canvas.drawPath(gainsPath, Paint()..color = AppColors.chartFill);

    _drawDashedLine(
      canvas,
      investedStart,
      investedEnd,
      Paint()
        ..color = AppColors.chartNeutral
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawPath(
      valuePath,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.restore();

    // Point final, affiché quand la courbe est entièrement tracée.
    if (progress > 0.97) {
      final end = pointFor(_steps, _value(_steps)).translate(-4, 0);
      canvas.drawCircle(end, 6, Paint()..color = Colors.white);
      canvas.drawCircle(end, 4.2, Paint()..color = AppColors.primary);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset from, Offset to, Paint paint) {
    const dash = 5.0;
    const gap = 5.0;

    final length = (to - from).distance;
    if (length == 0) {
      return;
    }
    final direction = (to - from) / length;

    var travelled = 0.0;
    while (travelled < length) {
      final segmentEnd = math.min(travelled + dash, length);
      canvas.drawLine(
        from + direction * travelled,
        from + direction * segmentEnd,
        paint,
      );
      travelled += dash + gap;
    }
  }

  @override
  bool shouldRepaint(GrowthChartPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
