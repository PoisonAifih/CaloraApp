import 'package:flutter/material.dart';

import '../api/models.dart';
import '../theme/calora_theme.dart';

class WeightChart extends StatelessWidget {
  const WeightChart({required this.weights, super.key});

  final List<WeightEntry> weights;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      width: double.infinity,
      child: CustomPaint(painter: _WeightPainter(weights)),
    );
  }
}

class _WeightPainter extends CustomPainter {
  _WeightPainter(this.weights);

  final List<WeightEntry> weights;
  final bool dark = CaloraColors.dark;

  @override
  void paint(Canvas canvas, Size size) {
    final points = [...weights]..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));
    if (points.length < 2) return;
    final values = points.map((item) => item.weightKg).toList();
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final span = (max - min).abs() < 0.1 ? 1.0 : max - min;
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = size.width * i / (points.length - 1);
      final y = size.height - ((points[i].weightKg - min) / span) * (size.height - 12) - 6;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = CaloraColors.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _WeightPainter oldDelegate) => oldDelegate.weights != weights || oldDelegate.dark != dark;
}
