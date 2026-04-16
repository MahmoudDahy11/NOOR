import 'package:flutter/material.dart';

import 'personal_progress_details.dart';

class PersonalProgressCard extends StatelessWidget {
  const PersonalProgressCard({
    super.key,
    required this.dhikr,
    required this.personalCount,
    required this.goal,
  });

  final String dhikr;
  final int personalCount;
  final int goal;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 140),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5E20).withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                dhikr,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
            ),
          ),
          PersonalProgressDetails(personalCount: personalCount, goal: goal),
        ],
      ),
    );
  }
}
