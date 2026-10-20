import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/calora_theme.dart';

class CalorieRing extends StatelessWidget {
  const CalorieRing({required this.consumed, required this.target, super.key, this.size = 92, this.stroke = 8, this.child});

  final double consumed;
  final double target;
  final double size;
  final double stroke;

  /// Drawn in the middle of the ring.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(consumed: consumed, target: target, stroke: stroke),
        child: child == null ? null : Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.consumed, required this.target, required this.stroke});

  final double consumed;
  final double target;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - stroke) / 2;
    final track = Paint()
      ..color = CaloraColors.cream
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    final ratio = target <= 0 ? 0.0 : consumed / target;
    final progress = Paint()
      ..color = ratio > 1 ? CaloraColors.tomato : CaloraColors.forest
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);
    final fraction = ratio.clamp(0.0, 1.0);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, fraction * math.pi * 2, false, progress);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.consumed != consumed || oldDelegate.target != target || oldDelegate.stroke != stroke;
  }
}
