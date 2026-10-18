import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/calora_theme.dart';

class CalorieRing extends StatelessWidget {
  const CalorieRing({required this.consumed, required this.target, super.key});

  final double consumed;
  final double target;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      height: 92,
      child: CustomPaint(painter: _RingPainter(consumed: consumed, target: target)),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.consumed, required this.target});

  final double consumed;
  final double target;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    final track = Paint()
      ..color = CaloraColors.ink.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    final progress = Paint()
      ..color = CaloraColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);
    final fraction = target <= 0 ? 0.0 : (consumed / target).clamp(0.0, 1.0);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, fraction * math.pi * 2, false, progress);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.consumed != consumed || oldDelegate.target != target;
  }
}
