import 'dart:math';

import 'package:flutter/material.dart';

class LiveCountRingPainter extends CustomPainter {
  LiveCountRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 14.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius,
      _paint(const Color(0xFF143D28), strokeWidth),
    );
    if (progress <= 0) return;
    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * progress,
      false,
      _paint(
        const Color(0xFFFFD700).withValues(alpha: 0.25),
        strokeWidth + 10,
        blur: 10,
      ),
    );
    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * progress,
      false,
      _paint(const Color(0xFFFFD700), strokeWidth),
    );
  }

  Paint _paint(Color color, double width, {double? blur}) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..maskFilter = blur == null
        ? null
        : MaskFilter.blur(BlurStyle.normal, blur);

  @override
  bool shouldRepaint(covariant LiveCountRingPainter oldDelegate) =>
      progress != oldDelegate.progress;
}
