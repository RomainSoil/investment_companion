import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Graphique d'illustration de l'écran de bienvenue : un placement régulier,
/// avec ses hausses et ses baisses. La surface grise est le montant versé,
/// la surface verte au-dessus correspond aux gains des intérêts composés.
///
/// Animation codée : un [AnimationController] fait passer une progression de
/// 0 à 1, et le dessin (voir [GrowthChartPainter]) ne révèle que la partie du
/// graphique correspondant à cette progression.
class GrowthChart extends StatefulWidget {
  const GrowthChart({super.key});

  @override
  State<GrowthChart> createState() => _GrowthChartState();
}

class _GrowthChartState extends State<GrowthChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Graphique : la valeur d’un placement régulier monte et baisse, mais '
          'les gains des intérêts composés s’ajoutent peu à peu au montant versé.',
      child: Column(
        children: [
          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: GrowthChartPainter(progress: _controller.value),
                  child: child,
                );
              },
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              _LegendItem(
                color: AppColors.chartNeutral,
                text: 'Montant versé',
              ),
              SizedBox(width: 16),
              _LegendItem(
                color: AppColors.primary,
                text: 'Intérêts composés',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(text, style: AppTextStyles.caption.copyWith(fontSize: 12)),
      ],
    );
  }
}

/// Dessine le graphique jusqu'à la fraction [progress] de sa largeur (0 à 1).
class GrowthChartPainter extends CustomPainter {
  GrowthChartPainter({required this.progress});

  final double progress;

  /// Rendement de chaque période : des hausses et des baisses, comme sur un
  /// vrai marché. Ce sont des valeurs d'illustration, pas des données réelles.
  static const List<double> _returns = [
    0.07, -0.03, 0.09, 0.05, -0.06, 0.16, 0.11, 0.22, //
    -0.15, 0.10, 0.06, 0.12, -0.2, 0.26, 0.11, 0.1, //
    -0.08, 0.22, 0.07, -0.11, 0.12, 0.13, 0.14, 0.05, //
  ];

  /// Versement de départ, puis versement ajouté à chaque période.
  static const double _deposit = 100;
  static const double _monthlyDeposit = 60;

  /// Valeur du placement à chaque période : la valeur précédente rapporte
  /// son rendement (intérêts composés), puis on ajoute le versement.
  static final List<double> _values = () {
    final values = [_deposit];
    for (final rate in _returns) {
      values.add(values.last * (1 + rate) + _monthlyDeposit);
    }
    return values;
  }();

  @override
  void paint(Canvas canvas, Size size) {
    final steps = _returns.length;
    final maxValue = _values.last * 1.1;

    Offset pointFor(int step, double amount) {
      return Offset(
        size.width * step / steps,
        size.height * (1 - amount / maxValue),
      );
    }

    // Montant versé : il augmente régulièrement, c'est une droite.
    final investedStart = pointFor(0, _deposit);
    final investedEnd = pointFor(steps, _deposit + _monthlyDeposit * steps);

    // Courbe de la valeur du placement.
    final valueLine = Path()..moveTo(investedStart.dx, investedStart.dy);
    for (var step = 1; step <= steps; step++) {
      final point = pointFor(step, _values[step]);
      valueLine.lineTo(point.dx, point.dy);
    }

    // Surface du montant versé : entre l'axe du bas et la droite.
    final investedArea = Path()
      ..moveTo(0, size.height)
      ..lineTo(investedStart.dx, investedStart.dy)
      ..lineTo(investedEnd.dx, investedEnd.dy)
      ..lineTo(size.width, size.height)
      ..close();

    // Surface des gains : entre la droite du montant versé et la courbe.
    final gainsArea = Path.from(valueLine)
      ..lineTo(investedEnd.dx, investedEnd.dy)
      ..close();

    // On ne laisse apparaître que la partie gauche du dessin, sur une largeur
    // proportionnelle à la progression de l'animation.
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width * progress, size.height));

    canvas.drawPath(investedArea, Paint()..color = AppColors.chartNeutral);
    canvas.drawPath(
      gainsArea,
      Paint()..color = AppColors.primary.withValues(alpha: 0.5),
    );
    canvas.drawPath(
      valueLine,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(GrowthChartPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
