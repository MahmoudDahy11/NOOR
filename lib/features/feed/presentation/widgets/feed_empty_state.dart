import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class FeedEmptyState extends StatelessWidget {
  final String tab;

  const FeedEmptyState({super.key, required this.tab});

  @override
  Widget build(BuildContext context) {
    final isPending = tab == 'pending';
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPending
                  ? Icons.hourglass_empty_rounded
                  : Icons.mosque_rounded,
              color: AppColors.primary, size: 36,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isPending ? 'No pending rooms' : 'No active rooms',
            style: const TextStyle(fontSize: 16,
                fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            isPending
                ? 'Rooms waiting to start will appear here.'
                : 'Be the first to create a room!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13,
                color: Colors.white.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }
}
