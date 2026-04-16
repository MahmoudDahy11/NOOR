import 'package:flutter/material.dart';

class LiveRoomBackground extends StatelessWidget {
  const LiveRoomBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _DotPainter(), child: const SizedBox.expand());
  }
}

class _DotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF143D28).withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    const spacing = 26.0;
    const radius = 1.2;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
