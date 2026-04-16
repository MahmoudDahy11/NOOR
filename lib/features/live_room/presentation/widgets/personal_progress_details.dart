import 'package:flutter/material.dart';

class PersonalProgressDetails extends StatelessWidget {
  const PersonalProgressDetails({
    super.key,
    required this.personalCount,
    required this.goal,
  });

  final int personalCount;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final progress = goal > 0 ? (personalCount / goal).clamp(0.0, 1.0) : 0.0;
    return Container(
      width: 140,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YOUR PROGRESS',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: Color(0xFF6B7280),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$personalCount',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1B5E20),
                    height: 1,
                  ),
                ),
                TextSpan(
                  text: ' /$goal',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: progress),
            duration: const Duration(milliseconds: 400),
            builder: (_, value, child) => ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: const Color(0xFFE0E0E0),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF1B5E20)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
