import 'dart:math';

import 'package:flutter/material.dart';

/// Large circular progress ring showing the **global room counter**.
///
/// Uses a [CustomPainter] for the gold ring with glow effect and
/// [TweenAnimationBuilder] for smooth progress transitions.
class LiveCountRing extends StatelessWidget {
  final int totalCount;
  final int goal;
  final bool isActive;

  const LiveCountRing({
    super.key,
    required this.totalCount,
    required this.goal,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal > 0 ? (totalCount / goal).clamp(0.0, 1.0) : 0.0;

    return Center(
      child: SizedBox(
        width: 280,
        height: 280,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Animated gold ring
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: progress),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (_, animatedProgress, child) {
                return CustomPaint(
                  size: const Size(280, 280),
                  painter: _RingPainter(
                    progress: animatedProgress,
                    bgColor: const Color(0xFF143D28),
                    fgColor: const Color(0xFFFFD700),
                    strokeWidth: 14,
                  ),
                );
              },
            ),

            // Inner content — label + count + badge
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'TOTAL LIVE COUNT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF81C784),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),

                // Animate a subtle pulse when the count changes
                TweenAnimationBuilder<double>(
                  key: ValueKey(totalCount),
                  tween: Tween(begin: 0.92, end: 1.0),
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  builder: (_, scale, child) =>
                      Transform.scale(scale: scale, child: child),
                  child: Text(
                    _formatCount(totalCount),
                    style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                ),

                const SizedBox(height: 14),
                if (isActive) const _LiveNowBadge(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Formats an integer with comma separators: 1245000 → 1,245,000
  static String _formatCount(int count) {
    if (count < 1000) return count.toString();
    final str = count.toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write(',');
      buf.write(str[i]);
    }
    return buf.toString();
  }
}

// =============================================================================
// Private widgets
// =============================================================================

class _LiveNowBadge extends StatelessWidget {
  const _LiveNowBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF4CAF50), width: 1),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: Color(0xFF76FF03)),
          SizedBox(width: 6),
          Text(
            'LIVE NOW',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFFE8F5E9),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Custom painter — circular progress ring with glow
// =============================================================================

class _RingPainter extends CustomPainter {
  final double progress;
  final Color bgColor;
  final Color fgColor;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.bgColor,
    required this.fgColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 1. Background ring
    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    if (progress <= 0) return;

    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;

    // 2. Glow behind the arc
    final glowPaint = Paint()
      ..color = fgColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 10
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      glowPaint,
    );

    // 3. Main foreground arc
    final fgPaint = Paint()
      ..color = fgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => progress != old.progress;
}
