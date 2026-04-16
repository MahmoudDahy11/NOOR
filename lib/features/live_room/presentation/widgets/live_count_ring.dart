import 'package:flutter/material.dart';

import 'live_count_badge.dart';
import 'live_count_formatter.dart';
import 'live_count_ring_painter.dart';

class LiveCountRing extends StatelessWidget {
  const LiveCountRing({
    super.key,
    required this.totalCount,
    required this.goal,
    required this.isActive,
  });

  final int totalCount;
  final int goal;
  final bool isActive;

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
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: progress),
              duration: const Duration(milliseconds: 500),
              builder: (_, value, child) => CustomPaint(
                size: const Size(280, 280),
                painter: LiveCountRingPainter(progress: value),
              ),
            ),
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
                TweenAnimationBuilder<double>(
                  key: ValueKey(totalCount),
                  tween: Tween(begin: 0.92, end: 1.0),
                  duration: const Duration(milliseconds: 180),
                  builder: (_, scale, child) =>
                      Transform.scale(scale: scale, child: child),
                  child: Text(
                    formatLiveCount(totalCount),
                    style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                if (isActive) const LiveCountBadge(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
