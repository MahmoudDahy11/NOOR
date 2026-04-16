import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class FeedHeader extends StatelessWidget {
  const FeedHeader({
    super.key,
    required this.unreadCount,
    required this.onNotificationTap,
  });

  final int unreadCount;
  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 20),
      decoration: const BoxDecoration(color: Color(0xFF0A1F14)),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Tally Islamic',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Live',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              const Text(
                'Rooms',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                  color: AppColors.gold,
                  height: 1.2,
                ),
              ),
            ],
          ),
          const Spacer(),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onNotificationTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.notifications_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                Positioned(
                  top: -4,
                  right: -4,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutBack,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: unreadCount <= 0
                        ? const SizedBox.shrink()
                        : Container(
                            key: ValueKey(unreadCount > 9 ? '9+' : unreadCount),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: const BoxDecoration(
                              color: AppColors.gold,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              unreadCount > 9 ? '9+' : '$unreadCount',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
